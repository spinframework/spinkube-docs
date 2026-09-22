---
title: Quickstart
description: Learn how to setup a Kubernetes cluster, install SpinKube and run your first Spin App.
weight: 2
aliases:
  - /docs/quickstart
  - /docs/spin-operator/quickstart
---

This Quickstart guide demonstrates how to set up a development Kubernetes cluster, install SpinKube and
deploy your first Spin application. This example creates a kind cluster with the Spin containerd shim pre-installed on all nodes. In production, you should use the runtime class manager to install and manage the lifecycle of the containerd shim. Jump to the [Helm installation](./installing-with-helm.md) for more production cluster installation instructions.

## Prerequisites

For this Quickstart guide, you will need:

- [kubectl](https://kubernetes.io/docs/tasks/tools/) - the Kubernetes CLI
- A container runtime, such as [Docker
  Desktop](https://docs.docker.com/get-docker/), [Rancher Desktop](https://rancherdesktop.io/) or [OrbStack](https://orbstack.dev/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) - a tool for running local development Kubernetes clusters using Docker container “nodes”.
- [Helm](https://helm.sh/docs/intro/install/) - the package manager for Kubernetes

### Set up Your Kubernetes Cluster

1. Create a Kubernetes cluster with a kind image that includes the
   [containerd-shim-spin](https://github.com/spinframework/containerd-shim-spin) prerequisite already
   installed. During creation of the kind cluster, we add containerd configuration to instruct containerd to use the Spin containerd shim for workloads scheduled with the `spin` runtime class.:

```console { data-plausible="copy-quick-create-kind" }
cat <<EOF | kind create cluster --name wasm-cluster --image ghcr.io/spinframework/containerd-shim-spin/kind:v0.26.0 --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.cri.v1.runtime".containerd.runtimes.spin]
    runtime_type = "io.containerd.spin.v2"
  [plugins."io.containerd.cri.v1.runtime".containerd.runtimes.spin.options]
    SystemdCgroup = true
EOF
```

2. Install cert-manager

```console { data-plausible="copy-quick-install-cert-manager" }
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.0/cert-manager.yaml
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n cert-manager
```

3. Apply the [Runtime
   Class](https://github.com/spinframework/spin-operator/blob/main/config/samples/spin-runtime-class.yaml)
   used for scheduling Spin apps onto nodes running the shim:

> Note: In a production cluster you likely want to customize the Runtime Class with a `nodeSelector`
> that matches nodes that have the shim installed. However, in the kind example, the shim is pre-configured on
> every node.

```console { data-plausible="copy-quick-apply-runtime-class" }
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.runtime-class.yaml
```

1. Apply the [Custom Resource Definitions]({{< ref "glossary#custom-resource-definition-crd" >}})
   used by the Spin Operator:

```console { data-plausible="copy-quick-apply-crd" }
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.crds.yaml
```

## Deploy the Spin Operator

Execute the following command to install the Spin Operator on the cluster using Helm. This will
create all of the Kubernetes resources required by Spin Operator under the Kubernetes namespace
`spin-operator`. It may take a moment for the installation to complete as dependencies are installed
and pods are spinning up.

```console { data-plausible="copy-quick-deploy-operator" }
# Install Spin Operator with Helm
helm upgrade --install spin-operator \
  --namespace spin-operator \
  --create-namespace \
  --version 0.6.1 \
  --wait \
  oci://ghcr.io/spinframework/charts/spin-operator
```

Lastly, create the [shim executor]({{< ref "glossary#spin-app-executor-crd" >}}):

```console { data-plausible="copy-quick-create-shim-executor" }
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.shim-executor.yaml
```

## Run the Sample Application

You are now ready to deploy Spin applications onto the cluster!

1. Create your first application in the same `spin-operator` namespace that the operator is running:

```console { data-plausible="copy-quick-deploy-sample" }
kubectl apply -f https://raw.githubusercontent.com/spinframework/spin-operator/main/config/samples/simple.yaml
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
