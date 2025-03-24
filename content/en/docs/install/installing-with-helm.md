---
title: Installing with Helm
description: This guide walks you through the process of installing SpinKube using [Helm](https://helm.sh).
date: 2024-02-16
tags: [Installation]
aliases:
  - /docs/spin-operator/installation/installing-with-helm
---

## Prerequisites

For this guide in particular, you will need:

- [kubectl](https://kubernetes.io/docs/tasks/tools/) - the Kubernetes CLI
- [Helm](https://helm.sh) - the package manager for Kubernetes

## Install Spin Operator With Helm

The following instructions are for installing Spin Operator using a Helm chart (using `helm
install`).

### Prepare the Cluster

Before installing the chart, you'll need to ensure the following are installed:

- [cert-manager](https://github.com/cert-manager/cert-manager) to automatically provision and manage
  TLS certificates (used by spin-operator's admission webhook system). For detailed installation
  instructions see [the cert-manager documentation](https://cert-manager.io/docs/installation/).

```shell
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.5/cert-manager.yaml
```

- [Kwasm Operator](https://github.com/kwasm/kwasm-operator) is required to install WebAssembly shims
  on Kubernetes nodes that don't already include them. Note that in the future this will be replaced
  by [runtime class manager]({{< ref "architecture#runtime-class-manager" >}}).

```shell
# Add Helm repository if not already done
helm repo add kwasm http://kwasm.sh/kwasm-operator/

# Install KWasm operator
helm install \
  kwasm-operator kwasm/kwasm-operator \
  --namespace kwasm \
  --create-namespace \
  --set kwasmOperator.installerImage=ghcr.io/spinkube/containerd-shim-spin/node-installer:v0.18.0

# Provision Nodes
kubectl annotate node --all kwasm.sh/kwasm-node=true
```

## Chart prerequisites

Now we have our dependencies installed, we can start installing the operator. This involves a couple
of steps that allow for further customization of Spin Applications in the cluster over time, but
here we install the defaults.

- First ensure the [Custom Resource Definitions (CRD)]({{< ref
  "glossary#custom-resource-definition-crd" >}}) are installed. This includes the SpinApp CRD
  representing Spin applications to be scheduled on the cluster.

```shell
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.crds.yaml
```

- Next we create a [RuntimeClass]({{< ref "glossary#runtime-class" >}}) that points to the `spin`
  handler called `wasmtime-spin-v2`. If you are deploying to a production cluster that only has a shim
  on a subset of nodes, you'll need to modify the RuntimeClass with a `nodeSelector:`:

```shell
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.runtime-class.yaml
```

- Finally, we create a `containerd-spin-shim` [SpinAppExecutor]({{< ref
  "glossary#spin-app-executor-crd" >}}). This tells the Spin Operator to use the RuntimeClass we
  just created to run Spin Apps:

```shell
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.shim-executor.yaml
```

### Installing the Spin Operator Chart

The following installs the chart with the release name `spin-operator`:

```shell
# Install Spin Operator with Helm
helm install spin-operator \
  --namespace spin-operator \
  --create-namespace \
  --version 0.5.0 \
  --wait \
  oci://ghcr.io/spinframework/charts/spin-operator
```

### Upgrading the Chart

Note that you may also need to upgrade the spin-operator CRDs in tandem with upgrading the Helm
release:

```shell
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.crds.yaml
```

To upgrade the `spin-operator` release, run the following:

```shell
# Upgrade Spin Operator using Helm
helm upgrade spin-operator \
  --namespace spin-operator \
  --version 0.5.0 \
  --wait \
  oci://ghcr.io/spinframework/charts/spin-operator
```

### Uninstalling the Chart

To delete the `spin-operator` release, run:

```shell
# Uninstall Spin Operator using Helm
helm delete spin-operator --namespace spin-operator
```

This will remove all Kubernetes resources associated with the chart and deletes the Helm release.

To completely uninstall all resources related to spin-operator, you may want to delete the
corresponding CRD resources and the RuntimeClass:

```shell
kubectl delete -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.shim-executor.yaml
kubectl delete -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.runtime-class.yaml
kubectl delete -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.crds.yaml
```
