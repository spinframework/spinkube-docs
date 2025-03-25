---
title: SpinKube
---

{{< blocks/cover title="Welcome to SpinKube" image_anchor="top" height="full" >}} <a class="btn
btn-lg btn-primary me-3 mb-4" href="{{< relref "/docs" >}}"> SpinKube Documentation <i class="fas
  fa-arrow-alt-circle-right ms-2"></i> </a>
<p class="lead mt-5">A new open source project that streamlines the experience of developing, deploying, and operating Wasm workloads on Kubernetes.</p>
{{< blocks/link-down color="info" >}}
{{< /blocks/cover >}}


{{% blocks/lead color="primary" %}}

SpinKube comprises the following open source projects.

<br /> <br />

<u>**Containerd Shim Spin**</u>

The [Containerd Shim Spin repository](https://github.com/spinframework/containerd-shim-spin) provides
shim implementations for running WebAssembly ([Wasm](https://webassembly.org/)) / Wasm System
Interface ([WASI](https://github.com/WebAssembly/WASI)) workloads using
[runwasi](https://github.com/deislabs/runwasi) as a library, whereby workloads built using the [Spin
framework](https://github.com/fermyon/spin) can function similarly to container workloads in a
Kubernetes environment.

<br /> <br />

<u>**Runtime Class Manager**</u>

The [Runtime Class Manager, also known as the Containerd Shim Lifecycle
Operator](https://github.com/spinframework/runtime-class-manager), is designed to automate and manage the
lifecycle of containerd shims in a Kubernetes environment. This includes tasks like installation,
update, removal, and configuration of shims, reducing manual errors and improving reliability in
managing WebAssembly (Wasm) workloads and other containerd extensions.

<br /> <br />

<u>**Spin Plugin for Kubernetes**</u>

The [Spin plugin for Kubernetes](https://github.com/spinframework/spin-plugin-kube), known as `spin
kube`, faciliates the translation of existing [Spin
applications](https://developer.fermyon.com/spin) into the Kubernetes custom resource that will be
deployed and managed on your cluster. This plugin works by taking your spin application manifest and
scaffolding it into a Kubernetes yaml, which can be deployed and managed with `kubectl`. This allows
Kubernetes to manage and run Wasm workloads in a way similar to traditional container workloads.

<br /> <br />

<u>**Spin Operator**</u>

The [Spin Operator](https://github.com/spinframework/spin-operator/) enables deploying Spin applications
to Kubernetes. The foundation of this project is built using the
[kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) framework. Spin Operator defines Spin
App Custom Resource Definitions (CRDs). Spin Operator watches SpinApp Custom Resources e.g. Spin app
image, replicas, schedulers and other user-defined values and realizes the desired state in the
Kubernetes cluster. Spin Operator introduces a host of functionality such as resource-based scaling,
event-driven scaling, and much more.

{{% /blocks/lead %}}
