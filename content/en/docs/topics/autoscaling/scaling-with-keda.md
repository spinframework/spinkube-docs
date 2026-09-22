---
title: Scaling Spin App With Kubernetes Event-Driven Autoscaling (KEDA)
description: This tutorial illustrates how one can horizontally scale Spin Apps in Kubernetes using Kubernetes Event-Driven Autoscaling (KEDA).
date: 2024-02-16
categories: [Spin Operator]
tags: [Tutorials, Autoscaling]
aliases:
  - /docs/spin-operator/tutorials/scaling-with-keda
---

[KEDA](https://keda.sh) extends Kubernetes to provide event-driven scaling capabilities, allowing it
to react to events from Kubernetes internal and external sources using [KEDA
scalers](https://keda.sh/docs/2.13/scalers/). KEDA provides a wide variety of scalers to define
scaling behavior base on sources like CPU, Memory, Azure Event Hubs, Kafka, RabbitMQ, and more. We
use a `ScaledObject` to dynamically scale the instance count of our SpinApp to meet the demand.

## Prerequisites

Please ensure the following tools are installed on your local machine:

- [kubectl](https://kubernetes.io/docs/tasks/tools/) - the Kubernetes CLI
- [Helm](https://helm.sh) - the package manager for Kubernetes
- [Docker](https://docs.docker.com/engine/install/) - for running kind
- [kind](https://kind.sigs.k8s.io/) - a development Kubernetes distribution that runs on Docker
- [Bombardier](https://pkg.go.dev/github.com/codesenberg/bombardier) - cross-platform HTTP
  benchmarking CLI

> We use kind to run a Kubernetes cluster locally as part of this tutorial, but you can follow these
> steps to configure KEDA autoscaling on your desired Kubernetes environment.

## Setting Up Kubernetes Cluster

Run the following command to create a Kubernetes cluster that has [the
containerd-shim-spin](https://github.com/spinframework/containerd-shim-spin) pre-requisites installed: If
you have a Kubernetes cluster already, or want to start with a more production ready SpinKube installation, follow the [Helm installation guide](../../install/installing-with-helm.md) instead, which include instructions for configuring the Runtime Class Manager for managing the lifecycle of the Spin containerd shim. The following `kind` cluster creation creates a three node cluster with containerd configuration to instruct containerd to use the Spin containerd shim for workloads scheduled with the `spin` runtime class. We are also exposing host port 8081 to make load testing easier in later steps.

```console
cat <<EOF | kind create cluster --name wasm-cluster-scale --image ghcr.io/spinframework/containerd-shim-spin/kind:v0.26.0 --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.cri.v1.runtime".containerd.runtimes.spin]
    runtime_type = "io.containerd.spin.v2"
  [plugins."io.containerd.cri.v1.runtime".containerd.runtimes.spin.options]
    SystemdCgroup = true
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 8081
    protocol: TCP
- role: worker
- role: worker
EOF
```

### Deploying Spin Operator and its dependencies

First, you have to install [cert-manager](https://github.com/cert-manager/cert-manager) to
automatically provision and manage TLS certificates (used by Spin Operator's admission webhook
system). For detailed installation instructions see [the cert-manager
documentation](https://cert-manager.io/docs/installation/).

```console
# Install cert-manager CRDs
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.0/cert-manager.crds.yaml

# Add and update Jetstack repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install the cert-manager Helm chart
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.20.0
```

Next, run the following commands to install the Spin [Runtime Class]({{<ref
"glossary#runtime-class">}}) and Spin Operator [Custom Resource Definitions (CRDs)]({{<ref
"glossary#custom-resource-definition-crd">}}):

> Note: In a production cluster you likely want to customize the Runtime Class with a `nodeSelector`
> that matches nodes that have the shim installed. However, in the kind example, they're installed on
> every node.

```console
# Install the RuntimeClass
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.runtime-class.yaml

# Install the CRDs
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.crds.yaml
```

Lastly, install Spin Operator using `helm` and the [shim executor]({{< ref
"glossary#spin-app-executor-crd" >}}) with the following commands:

```console
# Install Spin Operator
helm install spin-operator \
  --namespace spin-operator \
  --create-namespace \
  --version 0.6.1 \
  --wait \
  oci://ghcr.io/spinframework/charts/spin-operator

# Install the shim executor
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.shim-executor.yaml
```

Great, now you have Spin Operator up and running on your cluster. This means you’re set to create
and deploy SpinApps later on in the tutorial.

## Install an Ingress Controller

Install an ingress controller in your cluster. This example uses Traefik as the ingress controller for local routing in Kind. We are requiring that it is run on the control-plane node where the hostPort is exposed.

```sh
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik \
  --namespace traefik --create-namespace \
  --set deployment.kind=DaemonSet \
  --set service.type=ClusterIP \
  --set ports.web.hostPort=80 \
  --set tolerations[0].key=node-role.kubernetes.io/control-plane \
  --set tolerations[0].effect=NoSchedule \
  --set tolerations[0].operator=Exists \
  --set nodeSelector."kubernetes\.io/hostname"=wasm-cluster-scale-control-plane
kubectl wait --namespace traefik --for=condition=ready pod --selector=app.kubernetes.io/name=traefik --timeout=180s
```

## Set Up Ingress for the Spin App

Use the following command to set up ingress on your Kubernetes cluster. This ensures traffic can
reach your Spin App once we’ve created it in future steps:

```console
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
  annotations:
    ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: traefik
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: keda-spinapp
            port:
              number: 80
EOF
```

## Setting Up KEDA

Use the following command to setup KEDA on your Kubernetes cluster using Helm. Different deployment
methods are described at [Deploying KEDA on keda.sh](https://keda.sh/docs/2.13/deploy/):

```console
# Add the Helm repository
helm repo add kedacore https://kedacore.github.io/charts

# Update your Helm repositories
helm repo update

# Install the keda Helm chart into the keda namespace
helm install keda kedacore/keda --namespace keda --create-namespace
```

## Deploy Spin App and the KEDA ScaledObject

Next up we’re going to deploy the Spin App we will be scaling. You can find the source code of the
Spin App in the
[apps/cpu-load-gen](https://github.com/spinframework/spin-operator/tree/main/apps/cpu-load-gen) folder of
the Spin Operator repository.

We can take a look at the `SpinApp` and the KEDA `ScaledObject` definitions in our deployment files
below. As you can see, we have explicitly specified resource limits to `500m` of `cpu`
(`spec.resources.limits.cpu`) and `500Mi` of `memory` (`spec.resources.limits.memory`) per
`SpinApp`:

```yaml
# https://raw.githubusercontent.com/spinframework/spin-operator/main/config/samples/keda-app.yaml
apiVersion: core.spinkube.dev/v1alpha1
kind: SpinApp
metadata:
  name: keda-spinapp
spec:
  image: ghcr.io/spinkube/spin-operator/cpu-load-gen:20240311-163328-g1121986
  executor: containerd-shim-spin
  enableAutoscaling: true
  resources:
    limits:
      cpu: 500m
      memory: 500Mi
    requests:
      cpu: 100m
      memory: 400Mi
---
```

We will scale the instance count when we’ve reached a 50% utilization in `cpu`
(`spec.triggers[cpu].metadata.value`). We’ve also instructed KEDA to scale our SpinApp horizontally
within the range of 1 (`spec.minReplicaCount`) and 20 (`spec.maxReplicaCount`).:

```yaml
# https://raw.githubusercontent.com/spinframework/spin-operator/main/config/samples/keda-scaledobject.yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: cpu-scaling
spec:
  scaleTargetRef:
    name: keda-spinapp
  minReplicaCount: 1
  maxReplicaCount: 20
  triggers:
    - type: cpu
      metricType: Utilization
      metadata:
        value: "50"
```

> The Kubernetes documentation is the place to learn more about [limits and
> requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits).
> Consult the KEDA documentation to learn more about
> [ScaledObject](https://keda.sh/docs/2.13/concepts/scaling-deployments/#scaledobject-spec) and
> [KEDA's built-in scalers](https://keda.sh/docs/2.13/scalers/).

Let’s deploy the SpinApp and the KEDA ScaledObject instance onto our cluster with the following
command:

```console
# Deploy the SpinApp
kubectl apply -f https://raw.githubusercontent.com/spinframework/spin-operator/main/config/samples/keda-app.yaml
spinapp.core.spinkube.dev/keda-spinapp created

# Deploy the ScaledObject
kubectl apply -f https://raw.githubusercontent.com/spinframework/spin-operator/main/config/samples/keda-scaledobject.yaml
scaledobject.keda.sh/cpu-scaling created
```

You can see your running Spin application by running the following command:

```console
kubectl get spinapps

NAME          READY REPLICAS   EXECUTOR
keda-spinapp  1                containerd-shim-spin
```

You can also see your KEDA ScaledObject instance with the following command:

```console
kubectl get scaledobject

NAME          SCALETARGETKIND      SCALETARGETNAME   MIN   MAX   TRIGGERS   READY   ACTIVE   AGE
cpu-scaling   apps/v1.Deployment   keda-spinapp      1     20    cpu        True    True     7m
```

## Generate Load to Test Autoscale

Now let’s use Bombardier to generate traffic to test how well KEDA scales our SpinApp. The following
Bombardier command will attempt to establish 40 connections during a period of 3 minutes (or less).
If a request is not responded to within 5 seconds that request will timeout:

```console
# Generate a bunch of load
bombardier -c 40 -t 5s -d 3m http://localhost:8081
```

To watch the load, we can run the following command to get the status of our deployment:

```console
kubectl describe deploy keda-spinapp
...
---

Available      True    MinimumReplicasAvailable
Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   keda-spinapp-76db5d7f9f (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  84s   deployment-controller  Scaled up replica set hpa-spinapp-76db5d7f9f  to 2 from 1
  Normal  ScalingReplicaSet  69s   deployment-controller  Scaled up replica set hpa-spinapp-76db5d7f9f  to 4 from 2
  Normal  ScalingReplicaSet  54s   deployment-controller  Scaled up replica set hpa-spinapp-76db5d7f9f  to 8 from 4
  Normal  ScalingReplicaSet  39s   deployment-controller  Scaled up replica set hpa-spinapp-76db5d7f9f  to 16 from 8
  Normal  ScalingReplicaSet  24s   deployment-controller  Scaled up replica set hpa-spinapp-76db5d7f9f  to 20 from 16
```
