---
title: SpinKube
---

{{< blocks/cover title="Hyper-efficient serverless on Kubernetes, powered by WebAssembly."
image_anchor="top" height="full" >}} <a class="btn btn-lg btn-primary me-3 mb-4" href="/docs"> Get
  Started <i class="fas fa-arrow-alt-circle-right ms-2"></i> </a>
<p class="lead mt-5">SpinKube is an open source, Kubernetes native project that streamlines developing,
deploying, and operating WebAssembly (Wasm) workloads in Kubernetes - resulting in delivering smaller, more portable applications with exciting compute performance benefits.</p>
{{< blocks/link-down color="info" >}}
{{< /blocks/cover >}}


{{% blocks/lead color="secondary" %}}

SpinKube combines the <a href="https://github.com/spinframework/spin-operator">Spin operator</a>, <a
href="https://github.com/spinframework/containerd-shim-spin">containerd shim Spin</a>, and the <a
href="https://github.com/spinframework/runtime-class-manager">runtime class manager</a> (formerly <a
href="https://kwasm.sh/">KWasm</a>) open source projects with contributions from Microsoft, SUSE,
Liquid Reply, and Fermyon. By running applications at the Wasm abstraction layer, SpinKube gives
developers a more powerful, efficient and scalable way to optimize application delivery on
Kubernetes.


### Made with Contributions from:

|![Microsoft](../logo-microsoft.png)|![Liquid Reply](../logo-liquidreply.png)|![SUSE](../logo-suse.png)|![Fermyon](../logo-fermyon.png)|
|---|---|---|---|

### Overview

[**Spin Operator**](https://github.com/spinframework/spin-operator/) is a Kubernetes operator that enables
deploying and running Spin applications in Kubernetes. It houses the SpinApp and SpinAppExecutor CRDs
which are used for configuring the individual workloads and workload execution configuration such as
runtime class. Spin Operator introduces a host of functionality such as resource-based scaling,
event-driven scaling and much more.

[**Containerd Shim Spin**](https://github.com/spinframework/containerd-shim-spin) provides a shim for running Spin
workloads managed by containerd. The Spin workload uses this shim as a runtime class within Kubernetes enabling
these workloads to function similarly to container workloads in Pods in Kubernetes.

[**Runtime Class Manager**](https://github.com/spinframework/runtime-class-manager) is an operator that
automates and manages the lifecycle of containerd shims in a Kubernetes environment. This includes tasks
like installation, update, removal, and configuration of shims, reducing manual errors and improving
reliability in managing WebAssembly (Wasm) workloads and other containerd extensions.

[**Spin Kube Plugin**](https://github.com/spinframework/spin-plugin-kube) is a plugin for the [Spin](https://developer.fermyon.com/spin/v3/index) CLI
that aims to ease the experience for scaffolding, deploying and inspecting Spin workloads in Kubernetes.

### Get Involved

We have bi-weekly [community calls](https://docs.google.com/document/d/10is2YoNC0NpXw4_5lSyTfpPph9_A9wBissKGrpFaIrI/edit?usp=sharing) and a [Slack channel](https://cloud-native.slack.com/archives/C06PC7JA1EE). We would love to have you join us! <br>

Check out the [contribution guidelines](/docs/contrib/) to learn how to get involved with the project.

---

<img class="responsive mx-auto d-block"
    width="300"
    alt="cloud-native computing"
    src="../cloud-native-computing.svg">

<div class="text-center">We are a <a href="https://www.cncf.io">Cloud Native Computing Foundation</a> sandbox project.</div>

<p>
  <div class="text-center">The Linux Foundation® (TLF) has registered trademarks and uses trademarks. For a list of TLF trademarks, see <a href="https://www.linuxfoundation.org/trademark-usage">Trademark Usage</a></div>
</p>

{{% /blocks/lead %}}
