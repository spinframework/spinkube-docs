---
title: Installing with Helm
description: This guide walks you through the process of installing SpinKube using [Helm](https://helm.sh).
date: 2024-02-16
tags: [Installation]
weight: 4
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
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.0/cert-manager.yaml
```

- [Runtime Class Manager](https://github.com/spinframework/runtime-class-manager) is required to install WebAssembly shims on Kubernetes nodes that don't already include them. See more details at the project's [README.md](https://github.com/spinframework/runtime-class-manager/blob/main/README.md).

```shell
# Install Runtime Class Manager
helm upgrade --install runtime-class-manager  \
  --namespace runtime-class-manager \
  --create-namespace \
  --version 0.2.0 \
  oci://ghcr.io/spinframework/charts/runtime-class-manager

# Create Shim resource for installing the containerd-shim-spin binary
kubectl apply -f https://raw.githubusercontent.com/spinframework/runtime-class-manager/refs/tags/v0.2.0/config/samples/sample_shim_spin.yaml

# Label all Nodes where the shim should be installed (and thus where Spin Apps may run)
# Note: this specific key and value matches the nodeSelector configuration used in the Shim resource above
kubectl label node --all spin=true
```

You should now see a `wasmtime-spin-v2` RuntimeClass and all labeled Nodes should be ready to run Spin Apps.

## Chart prerequisites

Now we have our dependencies installed, we can start installing the operator. This involves a couple
of steps that allow for further customization of Spin Applications in the cluster over time, but
here we install the defaults.

- First ensure the [Custom Resource Definitions (CRD)]({{< ref
  "glossary#custom-resource-definition-crd" >}}) are installed. This includes the SpinApp CRD
  representing Spin applications to be scheduled on the cluster.

```shell
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.crds.yaml
```

- Finally, we create a `containerd-spin-shim` [SpinAppExecutor]({{< ref
  "glossary#spin-app-executor-crd" >}}). This tells the Spin Operator to use the RuntimeClass we
  just created to run Spin Apps:

```shell
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.shim-executor.yaml
```

### Installing the Spin Operator Chart

The following installs the chart with the release name `spin-operator`:

```shell
# Install Spin Operator with Helm
helm upgrade --install spin-operator \
  --namespace spin-operator \
  --create-namespace \
  --version 0.6.1 \
  --wait \
  oci://ghcr.io/spinframework/charts/spin-operator
```

Head over to the [Quickstart](./quickstart.md#run-the-sample-application) to deploy your first Spin App. Or, read on for how to upgrade or uninstall Spin Operator.

### Upgrading the Chart

Note that you may also need to upgrade the spin-operator CRDs in tandem with upgrading the Helm
release:

```shell
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.crds.yaml
```

To upgrade the `spin-operator` release, run the following:

```shell
# Upgrade Spin Operator using Helm
helm upgrade spin-operator \
  --namespace spin-operator \
  --version 0.6.1 \
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
corresponding CRD resources:

```shell
kubectl delete -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.shim-executor.yaml
kubectl delete -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.crds.yaml
```
