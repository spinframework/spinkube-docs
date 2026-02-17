---
title: Installing on Azure Kubernetes Service
description: In this tutorial you'll learn how to deploy SpinKube on Azure Kubernetes Service (AKS).
date: 2024-02-16
categories: [Spin Operator]
tags: [Tutorials]
weight: 5
aliases:
  - /docs/spin-operator/tutorials/deploy-on-azure-kubernetes-service
---

In this tutorial, you install Spin Operator on an Azure Kubernetes Service (AKS) cluster and deploy
a simple Spin application. You will learn how to:

- Deploy an AKS cluster
- Install Spin Operator Custom Resource Definitions
- Install and verify containerd shim via Runtime Class Manager
- Deploy a simple Spin App custom resource on your cluster

<!-- TODO: To learn more about any of these concepts, please visit the [Spin Operator Conceptual article](link-to-concept-article). -->

## Prerequisites

Please ensure you have the following tools installed before continuing:

- [kubectl](https://kubernetes.io/docs/tasks/tools/) - the Kubernetes CLI
- [Helm](https://helm.sh) - the package manager for Kubernetes
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) - cross-platform CLI
  for managing Azure resources

## Provisioning the necessary Azure Infrastructure

Before you dive into deploying Spin Operator on Azure Kubernetes Service (AKS), the underlying cloud
infrastructure must be provisioned. For the sake of this article, you will provision a simple AKS
cluster. (Alternatively, you can setup the AKS cluster following [this guide from
Microsoft](https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster?tabs=azure-cli).)

```shell
# Login with Azure CLI
az login

# Select the desired Azure Subscription
az account set --subscription <YOUR_SUBSCRIPTION>

# Create an Azure Resource Group
az group create --name rg-spin-operator \
    --location germanywestcentral

# Create an AKS cluster
az aks create --name aks-spin-operator \
    --resource-group rg-spin-operator \
    --location germanywestcentral \
    --node-count 1 \
    --tier free \
    --generate-ssh-keys
```

Once the AKS cluster has been provisioned, use the `aks get-credentials` command to download
credentials for `kubectl`:

```shell
# Download credentials for kubectl
az aks get-credentials --name aks-spin-operator \
    --resource-group rg-spin-operator
```

For verification, you can use `kubectl` to browse common resources inside of the AKS cluster:

```shell
# Browse namespaces in the AKS cluster
kubectl get namespaces

NAME              STATUS   AGE
default           Active   3m
kube-node-lease   Active   3m
kube-public       Active   3m
kube-system       Active   3m
```

## Deploying the Spin Operator

First, the [Custom Resource Definition (CRD)]({{< ref "glossary#custom-resource-definition-crd" >}})
and the [Runtime Class]({{< ref "glossary#runtime-class" >}}) for `wasmtime-spin-v2` must be
installed.

```shell
# Install the CRDs
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.crds.yaml
```

The following installs [cert-manager](https://github.com/cert-manager/cert-manager) which is
required to automatically provision and manage TLS certificates (used by the admission webhook
system of Spin Operator)

```shell
# Install cert-manager CRDs
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.crds.yaml

# Add and update Jetstack repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install the cert-manager Helm chart
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.14.3
```

The Spin Operator chart also has a dependency on [Runtime Class Manager](https://github.com/spinframework/runtime-class-manager), which is used to install the containerd Spin shim on the Kubernetes node(s):


```shell
# Install Runtime Class Manager
helm upgrade --install runtime-class-manager  \
  --namespace runtime-class-manager \
  --create-namespace \
<<<<<<< HEAD
  --set kwasmOperator.installerImage=ghcr.io/spinframework/containerd-shim-spin/node-installer:v0.23.0
=======
  --version 0.1.0 \
  oci://ghcr.io/spinframework/charts/runtime-class-manager
>>>>>>> fba2bbc (docs(content): updates per Runtime Class Manager replacing kwasm-operator)

# Create Shim resource for installing the containerd-shim-spin binary
kubectl apply -f https://raw.githubusercontent.com/spinframework/runtime-class-manager/refs/heads/main/config/samples/test_shim_spin.yaml

# Label all Nodes where the shim should be installed (and thus where Spin Apps may run)
# Note: this specific key and value matches the nodeSelector configuration used in the Shim resource above
kubectl label node --all spin=true
```

To verify `containerd-shim-spin` installation, you can inspect the logs from the Runtime Class Manager:

```shell
# Inspect logs from the Runtime Class Manager
kubectl logs -n runtime-class-manager -l app.kubernetes.io/name=runtime-class-manager

{"level":"info","shim":"spin-v2","time":"2026-02-05T22:33:18Z","message":"Deploying install-Job for Shim spin-v2 on node: kind-control-plane"}
{"level":"debug","job":"kind-control-plane-spin-v2-install","time":"2026-02-05T22:33:18Z","message":"Job Reconciliation started!"}
...
{"level":"info","job":"kind-control-plane-spin-v2-install","time":"2026-02-05T22:33:38Z","message":"Job kind-control-plane-spin-v2-install is Completed."}
```

The following installs the chart with the release name `spin-operator` in the `spin-operator`
namespace:

```shell
helm upgrade --install spin-operator \
  --namespace spin-operator \
  --create-namespace \
  --version 0.6.1 \
  --wait \
  oci://ghcr.io/spinframework/charts/spin-operator
```

Lastly, create the [shim executor]({{< ref "glossary#spin-app-executor-crd" >}})::

```console
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.shim-executor.yaml
```

## Deploying a Spin App to AKS

To validate the Spin Operator deployment, you will deploy a simple Spin App to the AKS cluster. The
following command will install a simple Spin App using the `SpinApp` CRD you provisioned in the
previous section:

```shell
# Deploy a sample Spin app
kubectl apply -f https://raw.githubusercontent.com/spinframework/spin-operator/main/config/samples/simple.yaml
```

## Verifying the Spin App

Configure port forwarding from port `8080` of your local machine to port `80` of the Kubernetes
service which points to the Spin App you installed in the previous section:

```shell
kubectl port-forward services/simple-spinapp 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

Send a HTTP request to [http://127.0.0.1:8080/hello](http://127.0.0.1:8080/hello) using
[`curl`](https://curl.se/):

```shell
# Send an HTTP GET request to the Spin App
curl -iX GET http://localhost:8080/hello
HTTP/1.1 200 OK
transfer-encoding: chunked
date: Mon, 12 Feb 2024 12:23:52 GMT

Hello world from Spin!%
```

## Removing the Azure infrastructure

To delete the Azure infrastructure created as part of this article, use the following command:

```shell
# Remove all Azure resources
az group delete --name rg-spin-operator \
    --no-wait \
    --yes
```
