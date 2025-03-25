---
title: Compatibility
description: A list of compatible Kubernetes distributions and platforms for running SpinKube.
categories: [Spin Operator]
tags: []
aliases:
- /docs/compatibility
---

See the following list of compatible Kubernetes distributions and platforms for running the [Spin
Operator](https://github.com/spinframework/spin-operator/):

 - [Amazon Elastic Kubernetes Service (EKS)](https://docs.aws.amazon.com/eks/)
 - [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/products/kubernetes-service)
 - [Civo Kubernetes](https://www.civo.com/kubernetes)
 - [Digital Ocean Kubernetes (DOKS)](https://www.digitalocean.com/products/kubernetes)
 - [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine)
 - [k3d](https://k3d.io)
 - [minikube](https://minikube.sigs.k8s.io/docs/) (explicitly pass `--container-runtime=containerd`
   and ensure you're on minikube version `>= 1.33`)
 - [Scaleway Kubernetes Kapsule](https://www.scaleway.com/en/kubernetes-kapsule/)

> **Disclaimer**: Please note that this is a working list of compatible Kubernetes distributions and
> platforms. For managed Kubernetes services, it's important to be aware that cloud providers may
> choose to discontinue support for specific dependencies, such as container runtimes. While we
> strive to maintain the accuracy of this documentation, it is ultimately your responsibility to
> verify with your Kubernetes provider whether the required dependencies are still supported.

### How to validate Spin Operator Compatibility

If you would like to validate Spin Operator's compatibility with a new specific Kubernetes
distribution or platform or simply test one of the platforms listed above yourself, follow these
steps for validation:

1. **Install the Spin Operator**: Begin by installing the Spin Operator within the Kubernetes
   cluster. This involves deploying the necessary dependencies and the Spin Operator itself. (See
   [Installing with Helm]({{< ref "installing-with-helm" >}}))

2. **Create, Package, and Deploy a Spin App**: Proceed by creating a Spin App, packaging it, and
   successfully deploying it within the Kubernetes environment. (See [Package and Deploy Spin
   Apps]({{< ref "packaging" >}}))

3. **Invoke the Spin App**: Once the Spin App is deployed, ensure at least one request was
   successfully served by the Spin App.

## Container Runtime Constraints

The Spin Operator requires the target nodes that would run Spin applications to support containerd
version [`1.6.26+`](https://github.com/containerd/containerd/releases/tag/v1.6.26) or
[`1.7.7+`](https://github.com/containerd/containerd/releases/tag/v1.7.7).

Use the `kubectl get nodes -o wide` command to see which container runtime is installed per node:

```shell
# Inspect container runtimes per node
kubectl get nodes -o wide
NAME                    STATUS   VERSION   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
generalnp-vmss000000    Ready    v1.27.9   Ubuntu 22.04.4 LTS   5.15.0-1056-azure   containerd://1.7.7-1
generalnp-vmss000001    Ready    v1.27.9   Ubuntu 22.04.4 LTS   5.15.0-1056-azure   containerd://1.7.7-1
generalnp-vmss000002    Ready    v1.27.9   Ubuntu 22.04.4 LTS   5.15.0-1056-azure   containerd://1.7.7-1

```
