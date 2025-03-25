---
title: SpinKube at a glance
description: A high level overview of the SpinKube sub-projects.
weight: 80
---

## spin-operator

[Spin Operator](https://github.com/spinframework/spin-operator/) is a [Kubernetes
operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) which empowers platform
engineers to deploy [Spin applications](https://developer.fermyon.com/spin) as custom resources to
their Kubernetes clusters. Spin Operator provides an elegant solution for platform engineers looking
to improve efficiency without compromising on performance while maintaining workload portability.

### Why Spin Operator?

By bringing the power of the Spin framework to Kubernetes clusters, Spin Operator provides
application developers and platform engineers with the best of both worlds. For developers, this
means easily building portable serverless functions that leverage the power and performance of Wasm
via the Spin developer tool. For platform engineers, this means using idiomatic Kubernetes
primitives (secrets, autoscaling, etc.) and tooling to manage these workloads at scale in a
production environment, improving their overall operational efficiency.

### How Does Spin Operator Work?

Built with the [kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) framework, Spin
Operator is a Kubernetes operator. Kubernetes operators are used to extend Kubernetes automation to
new objects, defined as custom resources, without modifying the Kubernetes API. The Spin Operator is
composed of two main components:
- A controller that defines and manages Wasm workloads on k8s.
- The "SpinApps" Custom Resource Definition (CRD).

![spin-operator diagram](../spin-operator-diagram.png)

SpinApps CRDs can be [composed manually]({{< ref "glossary#custom-resource-definition-crd" >}}) or
generated automatically from an existing Spin application using the [`spin kube
scaffold`](#spin-plugin-kube) command. The former approach lends itself well to CI/CD systems,
whereas the latter is a better fit for local testing as part of a local developer workflow.

Once an application deployment begins, Spin Operator handles scheduling the workload on the
appropriate nodes (thanks to the [Runtime Class Manager](#runtime-class-manager), previously known
as Kwasm) and managing the resource's lifecycle. There is no need to fetch the
[`containerd-shim-spin`](#containerd-shim-spin) binary or mutate node labels. This is all managed
via the Runtime Class Manager, which you will install as a dependency when setting up Spin Operator.

## containerd-shim-spin

The [`containerd-shim-spin`](https://github.com/spinframework/containerd-shim-spin) is a [containerd
shim](https://github.com/containerd/containerd/blob/main/core/runtime/v2/README.md#runtime-shim)
implementation for [Spin](https://developer.fermyon.com/spin), which enables running Spin workloads
on Kubernetes via [runwasi](https://github.com/deislabs/runwasi). This means that by installing this
shim onto Kubernetes nodes, we can add a [runtime
class](https://kubernetes.io/docs/concepts/containers/runtime-class/) to Kubernetes and schedule
Spin workloads on those nodes. Your Spin apps can act just like container workloads!

The `containerd-shim-spin` is specifically designed to execute applications built with
[Spin](https://www.fermyon.com/spin) (a developer tool for building and running serverless Wasm
applications). The shim ensures that Wasm workloads can be managed effectively within a Kubernetes
environment, leveraging containerd's capabilities.

In a Kubernetes cluster, specific nodes can be bootstrapped with Wasm runtimes and labeled
accordingly to facilitate the scheduling of Wasm workloads. `RuntimeClasses` in Kubernetes are used
to schedule Pods to specific nodes and target specific runtimes. By defining a `RuntimeClass` with
the appropriate `NodeSelector` and handler, Kubernetes can direct Wasm workloads to nodes equipped
with the necessary Wasm runtimes and ensure they are executed with the correct runtime handler.

Overall, the Containerd Shim Spin represents a significant advancement in integrating Wasm workloads
into Kubernetes clusters, enhancing the versatility and capabilities of container orchestration.

## runtime-class-manager

The [Runtime Class Manager, also known as the Containerd Shim Lifecycle
Operator](https://github.com/spinframework/runtime-class-manager), is designed to automate and manage the
lifecycle of containerd shims in a Kubernetes environment. This includes tasks like installation,
update, removal, and configuration of shims, reducing manual errors and improving reliability in
managing WebAssembly (Wasm) workloads and other containerd extensions.

The Runtime Class Manager provides a robust and production-ready solution for installing, updating,
and removing shims, as well as managing node labels and runtime classes in a Kubernetes environment.

By automating these processes, the runtime-class-manager enhances reliability, reduces human error,
and simplifies the deployment and management of containerd shims in Kubernetes clusters.

## spin-plugin-kube

The [Kubernetes plugin for Spin](https://github.com/spinframework/spin-plugin-kube) is designed to
enhance Spin by enabling the execution of Wasm modules directly within a Kubernetes cluster.
Specifically a tool designed for Kubernetes integration with the Spin command-line interface. This
plugin works by integrating with containerd shims, allowing Kubernetes to manage and run Wasm
workloads in a way similar to traditional container workloads.

The Kubernetes plugin for Spin allows developers to use the Spin command-line interface for
deploying Spin applications; it provides a seamless workflow for building, pushing, deploying, and
managing Spin applications in a Kubernetes environment. It includes commands for scaffolding new
components as Kubernetes manifests, and deploying and retrieving information about Spin applications
running in Kubernetes. This plugin is an essential tool for developers looking to streamline their
Spin application deployment on Kubernetes platforms.
