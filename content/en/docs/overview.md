---
title: Overview
description: A high level overview of the SpinKube sub-projects.
weight: 1
categories: [SpinKube]
tags: []
---

# Project Overview

[SpinKube](https://github.com/spinframework) is an open source project that streamlines the
experience of deploying and operating Wasm workloads on Kubernetes, using [Spin
Operator](https://github.com/spinframework/spin-operator) in tandem with
[runwasi](https://github.com/containerd/runwasi) and [runtime class
manager](https://github.com/spinframework/runtime-class-manager).

With SpinKube, you can leverage the advantages of using WebAssembly (Wasm) for your workloads:

- Artifacts are significantly smaller in size compared to container images.
- Artifacts can be quickly fetched over the network and started much faster (\*Note: We are aware of
  several optimizations that still need to be implemented to enhance the startup time for
  workloads).
- Substantially fewer resources are required during idle times.

Thanks to SpinKube, we can do all of this while integrating with Kubernetes primitives including
DNS, probes, autoscaling, metrics, and many more cloud native and CNCF projects.

![SpinKube Project Overview Diagram](../spinkube-overview-diagram.png)

SpinKube watches [Spin App Custom Resources]({{< ref "glossary#spinapp-manifest" >}}) and realizes
the desired state in the Kubernetes cluster. The foundation of this project was built using the
[kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) framework and contains a Spin App
Custom Resource Definition (CRD) and controller.

SpinKube is a [Cloud Native Computing Foundation](https://www.cncf.io/) sandbox project.

To get started, check out our [Quickstart guide]({{< ref "quickstart" >}}).
