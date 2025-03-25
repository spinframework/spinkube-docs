---
title: Selective Deployments in Spin
description: Learn how to deploy a subset of components from your SpinApp using Selective Deployments.
date: 2024-11-10
categories: [Spin Operator]
tags: [Tutorials]
weight: 10
---

This article explains how to selectively deploy a subset of components from your Spin App using Selective Deployments. You will learn how to:

- Scaffold a Specific Component from a Spin Application into a Custom Resource
- Run a Selective Deployment

Selective Deployments allow you to control which components within a Spin app are active for a specific instance of the app. With Component Selectors, Spin and SpinKube can declare at runtime which components should be activated, letting you deploy a single, versioned artifact while choosing which parts to enable at startup. This approach separates developer goals (building a well-architected app) from operational needs (optimizing for specific infrastructure).

## Prerequisites

For this tutorial, you’ll need:

- [kubectl](https://kubernetes.io/docs/tasks/tools/) - the Kubernetes CLI
- Kubernetes cluster with the Spin Operator v0.4 and Containerd Spin Shim v0.17 - follow the [Quickstart](../install/quickstart.md) if needed
- `spin kube` plugin v0.3 - follow [Installing the `spin kube` plugin](../install/spin-kube-plugin.md) if needed

## Scaffold a Specific Component from a Spin Application into a Custom Resource

We’ll use a sample application called "Salutations", which demonstrates greetings via two components, each responding to a unique HTTP route. If we take a look at the [application manifest](https://github.com/spinframework/spin-operator/blob/main/apps/salutations/spin.toml), we’ll see that this Spin application is comprised of two components:

- `Hello` component triggered by the `/hi` route
- `Goodbye` component triggered by the `/bye` route

```yaml
spin_manifest_version = 2

[application]
name = "salutations"
version = "0.1.0"
authors = ["Kate Goldenring <kate.goldenring@fermyon.com>"]
description = "An app that gives salutations"

[[trigger.http]]
route = "/hi"
component = "hello"

[component.hello]
source = "../hello-world/main.wasm"
allowed_outbound_hosts = []
[component.hello.build]
command = "cd ../hello-world && tinygo build -target=wasi -gc=leaking -no-debug -o main.wasm main.go"
watch = ["**/*.go", "go.mod"]

[[trigger.http]]
route = "/bye"
component = "goodbye"

[component.goodbye]
source = "main.wasm"
allowed_outbound_hosts = []
[component.goodbye.build]
command = "tinygo build -target=wasi -gc=leaking -no-debug -o main.wasm main.go"
watch = ["**/*.go", "go.mod"]
```

With Selective Deployments, you can choose to deploy only specific components without modifying the source code. For this example, we’ll deploy just the `hello` component.

> Note that if you had an Spin application with more than two components, you could choose to deploy multiple components selectively.

To Selectively Deploy, we first need to turn our application into a SpinApp Custom Resource with the `spin kube scaffold` command, using the optional `--component` field to specify which component we’d like to deploy:

```bash
spin kube scaffold --from ghcr.io/spinkube/spin-operator/salutations:20241105-223428-g4da3171 --component hello --replicas 1 --out spinapp.yaml
```

Now if we take a look at our `spinapp.yaml`, we should see that only the hello component will be deployed via Selective Deployments:

```yaml
apiVersion: core.spinkube.dev/v1alpha1
kind: SpinApp
metadata:
  name: salutations
spec:
  image: "ghcr.io/spinkube/spin-operator/salutations:20241105-223428-g4da3171"
  executor: containerd-shim-spin
  replicas: 1
  components:
  - hello
```

## Run a Selective Deployment

Now you can deploy your app using `kubectl` as you normally would:

```bash
# Deploy the spinapp.yaml using kubectl
kubectl apply -f spinapp.yaml
spinapp.core.spinkube.dev/salutations created
```

We can test that only our `hello` component is running by port-forwarding its service.

```bash
kubectl port-forward svc/salutations 8083:80
```

Now let’s call the `/hi` route in a seperate terminal:

```bash
curl localhost:8083/hi
```

If the hello component is running correctly, we should see a response of "Hello Fermyon!":

```bash
Hello Fermyon!
```

Next, let’s try the `/bye` route. This should return nothing, confirming that only the `hello` component was deployed:

```bash
curl localhost:8083/bye
```

There you have it! You selectively deployed a subset of your Spin application to SpinKube with no modifications to your source code. This approach lets you easily deploy only the components you need, which can improve efficiency in environments where only specific services are required.
