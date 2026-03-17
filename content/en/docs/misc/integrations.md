---
title: Integrations
description: A high level overview of the SpinKube integrations.
categories: [SpinKube]
tags: [Integrations]
aliases:
- /docs/integrations
---

# SpinKube Integrations

## KEDA

[Kubernetes Event-Driven Autoscaling (KEDA)](https://keda.sh/) provides event-driven autoscaling for
Kubernetes workloads. It allows Kubernetes to automatically scale applications in response to
external events such as messages in a queue, enabling more efficient resource utilization and
responsive scaling based on actual demand, rather than static metrics. KEDA serves as a bridge
between Kubernetes and various event sources, making it easier to scale applications dynamically in
a cloud-native environment. If you would like to see how SpinKube integrates with KEDA, please read
the ["Scaling With KEDA" tutorial]({{< ref "scaling-with-keda" >}}) which deploys a SpinApp and the
KEDA ScaledObject instance onto a cluster. The tutorial also uses Bombardier to generate traffic to
test how well KEDA scales our SpinApp.

## Rancher Desktop

The [release of Rancher Desktop
1.13.0](https://www.suse.com/c/rancher_blog/rancher-desktop-1-13-with-support-for-webassembly-and-more/)
comes with basic support for running WebAssembly (Wasm) containers and deploying them to Kubernetes.
Rancher Desktop by SUSE, is an open-source application that provides all the essentials to work with
containers and Kubernetes on your desktop. If you would like to see how SpinKube integrates with
Rancher Desktop, please read the ["Integrating With Rancher Desktop" tutorial]({{< ref
"/docs/install/rancher-desktop" >}}) which walks through the steps of installing the necessary
components for SpinKube (including the CertManager for SSL, CRDs and the Runtime Class Manager
using Helm charts). The tutorial then demonstrates how to create a simple Spin JavaScript
application and deploys the application within Rancher Desktop's local cluster.
