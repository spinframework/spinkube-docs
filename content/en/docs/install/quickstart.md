---
title: Quickstart
description: Learn how to setup a Kubernetes cluser, install SpinKube and run your first Spin App.
weight: 2
aliases:
  - /docs/quickstart
  - /docs/spin-operator/quickstart
---

This Quickstart guide demonstrates how to set up a new Kubernetes cluster, install the SpinKube and
deploy your first Spin application.

## Prerequisites

For this Quickstart guide, you will need:

- [kubectl](https://kubernetes.io/docs/tasks/tools/) - the Kubernetes CLI
- [Rancher Desktop](https://rancherdesktop.io/) or [Docker
  Desktop](https://docs.docker.com/get-docker/) for managing containers and Kubernetes on your
  desktop
- [k3d](https://k3d.io/v5.6.0/?h=installation#installation) - a lightweight Kubernetes distribution
  that runs on Docker
- [Helm](https://helm.sh/docs/intro/install/) - the package manager for Kubernetes

### Set up Your Kubernetes Cluster

1. Create a Kubernetes cluster with a k3d image that includes the
   [containerd-shim-spin](https://github.com/spinkube/containerd-shim-spin) prerequisite already
   installed:

```console { data-plausible="copy-quick-create-k3d" }
k3d cluster create wasm-cluster \
  --image ghcr.io/spinkube/containerd-shim-spin/k3d:v0.18.0 \
  --port "8081:80@loadbalancer" \
  --agents 2
```

> Note: Spin Operator requires a few Kubernetes resources that are installed globally to the
> cluster. We create these directly through `kubectl` as a best practice, since their lifetimes are
> usually managed separately from a given Spin Operator installation.

2. Install cert-manager

```console { data-plausible="copy-quick-install-cert-manager" }
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.yaml
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n cert-manager
```

3. Apply the [Runtime
   Class](https://github.com/spinkube/spin-operator/blob/main/config/samples/spin-runtime-class.yaml)
   used for scheduling Spin apps onto nodes running the shim:

> Note: In a production cluster you likely want to customize the Runtime Class with a `nodeSelector`
> that matches nodes that have the shim installed. However, in the K3d example, they're installed on
> every node.

```console { data-plausible="copy-quick-apply-runtime-class" }
kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.5.0/spin-operator.runtime-class.yaml
```

4. Apply the [Custom Resource Definitions]({{< ref "glossary#custom-resource-definition-crd" >}})
   used by the Spin Operator:

```console { data-plausible="copy-quick-apply-crd" }
kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.5.0/spin-operator.crds.yaml
```

## Deploy the Spin Operator

Execute the following command to install the Spin Operator on the K3d cluster using Helm. This will
create all of the Kubernetes resources required by Spin Operator under the Kubernetes namespace
`spin-operator`. It may take a moment for the installation to complete as dependencies are installed
and pods are spinning up.

```console { data-plausible="copy-quick-deploy-operator" }
# Install Spin Operator with Helm
helm install spin-operator \
  --namespace spin-operator \
  --create-namespace \
  --version 0.5.0 \
  --wait \
  oci://ghcr.io/spinkube/charts/spin-operator
```

Lastly, create the [shim executor]({{< ref "glossary#spin-app-executor-crd" >}}):

```console { data-plausible="copy-quick-create-shim-executor" }
kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.5.0/spin-operator.shim-executor.yaml
```

## Run the Sample Application

You are now ready to deploy Spin applications onto the cluster!

1. Create your first application in the same `spin-operator` namespace that the operator is running:

```console { data-plausible="copy-quick-deploy-sample" }
kubectl apply -f https://raw.githubusercontent.com/spinkube/spin-operator/main/config/samples/simple.yaml
```

2. Forward a local port to the application pod so that it can be reached:

```console { data-plausible="copy-quick-forward-local-port" }
kubectl port-forward svc/simple-spinapp 8083:80
```

3. In a different terminal window, make a request to the application:

```console { data-plausible="copy-quick-make-request" }
curl localhost:8083/hello
```

You should see:

```bash
Hello world from Spin!
```

## Next Steps

Congrats on deploying your first SpinApp! Recommended next steps:

- Scale your [Spin Apps with Horizontal Pod Autoscaler (HPA)]({{< ref "scaling-with-hpa" >}})
- Scale your [Spin Apps with Kubernetes Event Driven Autoscaler (KEDA)]({{< ref "scaling-with-keda"
  >}})
