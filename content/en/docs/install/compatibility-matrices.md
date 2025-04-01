---
title: Executor Compatibility Matrices
description: A set of compatibility matrices for each SpinKube executor
date: 2024-11-08
categories: [Spin Operator]
tags: [reference]
---

## `containerd-shim-spin` Executor

The [Spin containerd shim](https://github.com/spinframework/containerd-shim-spin) project is a containerd shim implementation for Spin.

### Spin Operator and Shim Feature Map

If a feature is configured in a `SpinApp` that is not supported in the version of the shim being
used, the application may not execute as expected. The following maps out the versions of the [Spin
containerd shim](https://github.com/spinframework/containerd-shim-spin), Spin Operator, and `spin kube`
plugin that have support for specific features.

| Feature              | SpinApp field | Shim Version | Spin Operator Version | `spin kube` plugin version |
| -------------------- | ------------- | ------------ | --------------------- | -------------------------- |
| OTEL Traces          | `otel`        | v0.15.0      | v0.3.0                | NA                         |
| Selective Deployment | `components`  | v0.17.0      | v0.4.0                | v0.3.0                     |

> NA indicates that the feature in not available yet in that project

### Spin and Spin Containerd Shim Version Map

For tracking the availability of Spin features and compatibility of Spin SDKs, the following
indicates which versions of the Spin runtime the [Spin containerd
shim](https://github.com/spinframework/containerd-shim-spin) uses.

| **shim version** | v0.12.0                                                       | v0.13.0                                                       | v0.14.0                                                       | v0.14.1                                                       | v0.15.0                                                       | v0.15.1                                                       | v0.16.0                                                       | v0.17.0                                                       | v0.18.0                                                       | v0.19.0                                                       |
| ---------------- | ------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------- |
| **spin**         | [v2.2.0](https://github.com/fermyon/spin/releases/tag/v2.2.0) | [v2.3.1](https://github.com/fermyon/spin/releases/tag/v2.3.1) | [v2.4.2](https://github.com/fermyon/spin/releases/tag/v2.4.2) | [v2.4.3](https://github.com/fermyon/spin/releases/tag/v2.4.3) | [v2.6.0](https://github.com/fermyon/spin/releases/tag/v2.6.0) | [v2.6.0](https://github.com/fermyon/spin/releases/tag/v2.6.0) | [v2.6.0](https://github.com/fermyon/spin/releases/tag/v2.6.0) | [v3.0.0](https://github.com/fermyon/spin/releases/tag/v3.0.0) | [v3.1.2](https://github.com/fermyon/spin/releases/tag/v3.1.2) | [v3.2.0](https://github.com/fermyon/spin/releases/tag/v3.2.0) |
