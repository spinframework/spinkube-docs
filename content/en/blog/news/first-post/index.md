---
date: 2024-03-13
title: Introducing SpinKube
linkTitle: Introducing SpinKube
description: >
  Bringing the next wave of hyper-efficient serverless to Kubernetes.
author: The SpinKube Team ([@SpinKube](https://mastodon.social/@SpinKube))
resources:
  - src: "**.{png,jpg}"
    title: "Image #:counter"
---
Today we're introducing SpinKube - an open source platform for efficiently running Spin-based
WebAssembly (Wasm) applications on Kubernetes. Built with love by folks from Microsoft, SUSE,
LiquidReply, and Fermyon.

SpinKube combines the application lifecycle management of the [Spin Operator][spin-operator], the
efficiency of the [containerd-shim-spin][containerd-shim-spin], and the node lifecycle management of
the forthcoming [runtime-class-manager][runtime-class-manager] (formerly [KWasm][kwasm]) to provide
an excellent developer and operator experience alongside excellent density and scaling
characteristics regardless of processor architecture or deployment environment.

>
> TL;DR? Check out the [quickstart][quickstart] to learn how to deploy Wasm to Kubernetes today.
>

## Why Serverless?

Containers and Kubernetes revolutionized the field of software development and operations. A unified
packaging and dependency management system that was flexible enough to allow most applications to
become portable - to run the same versions locally as you did in production - was a desperately
needed iteration from the Virtual Machines that came before.

But while containers give us a relatively light weight abstraction layer, they come with a variety
of issues:

- *Change management* - patching system dependencies (such as OpenSSL) need to happen on every image
  independently, which can become difficult to manage at large scale.
- *Rightsizing workloads* - managing access to shared resources like CPU and memory correctly is
  difficult, which often leads to over-provisioning resources (over introducing downtime) resulting
  in low utilization of host resources.
- *Size* - containers are often bigger than needed (impacting important metrics like startup time),
  and often include extraneous system dependencies by default which are not required to run the
  application.

The desire to fix many of these issues is what led to the "first" generation of serverless.

>
> Borrowing ideas from CGI, serverless apps are not written as persistent servers. Instead
> serverless code responds to events (such as HTTP requests) - but does not run as a daemon process
> listening on a socket. The networking part of serverless architectures is delegated to the
> underlying infrastructure.
>

First-generation serverless runtimes (such as AWS Lambda, Google Cloud Functions, Azure Functions,
and their Kubernetes counterparts OpenWhisk and KNative) are all based on the principle of running a
VM or container per function. While this afforded flexibility for application developers, complexity
was introduced to platform engineers as neither compute type is designed to start quickly. Platform
engineers operating these serverless platforms became responsible for an elaborate dance of
pre-warming compute capacity and loading a workload just in time, making for a difficult tradeoff in
cold start performance and cost. The result? A slow and inefficient first generation of Serverless.

To illustrate this point, below are all the steps required to start a Kubernetes Pod:

| Phase | Description |
| --- | --- |
| Kube init | Kubernetes schedules a Pod to a node, the node then prepares to run the Pod |
| Image pull (cacheable) | The node pulls the container images from a remote repository to a local cache when needed |
| Image mount | The node prepares the container images and mounts them |
| Container start | The node configures and starts the Pod's containers and sidecars |
| Application load | Each container loads application code and libraries, and initializes application memory |
| Application initialization | Each container performs application-specific init code (entry-point, setting up telemetry, validating connections to external dependencies, etc.) |
| Pod ready | The Pod responds to the asynchronous readiness probe and signals that it is now ready |
| Service ready | The Pod gets added to the list of active endpoints for a Service and can start receiving traffic |

Optimizing this process and reducing the deplication that occurs on every replica (even when running
on the same node) is where [Spin][spin] the Wasm runtime and SpinKube start to shine.

## Why SpinKube?

SpinKube solves or mitigates many of the issues commonly associated with deploying, scaling, and
operating serverless applications.

The foundational work that underpins the majority of this comes from removing the Container. Spin
Applications are primarily distributed as OCI Artifacts, rather than traditional container images,
meaning that you only ship your compiled application and its assets - without system dependencies.

To execute those applications we have a [runwasi](https://github.com/containerd/runwasi) based
[containerd-shim-spin](https://github.com/spinframework/containerd-shim-spin/) that takes a Spin app,
[pre-compiles it for the specific
architecture](https://github.com/spinframework/containerd-shim-spin/pull/32) (caching the result in the
containerd content store), and is then ready to service requests with [sub-millisecond startup
times](https://fermyon.github.io/spin-benchmarks/criterion/reports/spin-executor_sleep-1ms/index.html)
- no matter how long your application has been sitting idle.

This also has the benefit of moving the core security patching of web servers, queue listeners, and
other application boundaries to the host, rather than image artifacts themselves.

But what if you mostly rely on images provided by your cloud provider? Or deploy to environments
that are not easily reproducible?

This is where [runtime-class-manager][runtime-class-manager] (coming soon, formerly [KWasm][kwasm])
comes into play - a Production Ready and Kubernetes-native way to manage WebAssembly runtimes on
Kubernetes Hosts. With runtime-class-manager you can ensure that containerd-shim-spin is installed
on your hosts, manage version lifecycles, and security patches - all from the Kubernetes API.

By combining these technologies, scaling a Wasm application looks more like this:

| Phase | Description |
| --- | --- |
| Kube init | Kubernetes schedules a Pod to a node, the node then prepares to run the Pod |
| Image pull (cacheable) | The node pulls the needed container images from a remote repository to a local cache when needed |
| Wasm Load (cachable) | The shim loads the Wasm and prepares it for execution on the node’s CPU architecture |
| Application start | The shim starts listening on the configured port and is ready to serve |
| Pod ready | The Pod responds to the asynchronous readiness probe and signals that it is now ready |
| Service ready | The Pod gets added to the list of active endpoints for a Service and can start receiving traffic |

Or in practice:

<video src="spinkube-scaling.mp4" width="80%" controls></video>


## Deploying applications

This leaves one major area that can be painful when deploying applications to Kubernetes today: the
developer and deployment experience.

This is where [Spin][spin], [the `spin kube` plugin](https://github.com/spinframework/spin-plugin-kube),
and [`spin-operator`][spin-operator] start to shine.

![Architecture diagram of the SpinKube project](spinkube-diagram.png)

The spin-operator makes managing serverless applications easy - you provide the image and bindings
to secrets, and the operator handles realizing that configuration as regular Kubernetes objects.

Combining the operator with the `spin kube` plugin gives you superpowers, as it streamlines the
process of generating Kubernetes YAML for your application and gives you a powerful starting point
for applications.

This is all it takes to get a HTTP application running on Kubernetes (after installing the
containerd shim and the operator):

```bash
# Create a new Spin App
spin new -t http-rust --accept-defaults spin-kube-app
cd spin-kube-app

# Build the Spin App
spin build

# Push the Spin App to an OCI registry
export IMAGE_NAME=ttl.sh/spin-app-$(uuidgen):1h
spin registry push $IMAGE_NAME

# Scaffold Kubernetes manifests
spin kube scaffold -f $IMAGE_NAME > app.yaml

# Deploy to Kubernetes
kubectl apply -f app.yaml
```

If you want to try things out yourself, the easiest way is to follow the [quickstart
guide][quickstart] - we can’t wait to see what you build.

[spin-operator]: https://github.com/spinframework/spin-operator
[containerd-shim-spin]: https://github.com/spinframework/containerd-shim-spin
[runtime-class-manager]: https://github.com/spinframework/runtime-class-manager
[spin]: https://github.com/fermyon/spin
[quickstart]: https://www.spinkube.dev/docs/spin-operator/quickstart/
[kwasm]: https://kwasm.sh/
