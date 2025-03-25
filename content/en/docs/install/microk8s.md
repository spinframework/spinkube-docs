---
title: Installing on Microk8s
description: This guide walks you through the process of installing SpinKube using [Microk8s](https://microk8s.io/).
date: 2024-06-19
tags: [Installation]
---

This guide walks through the process of installing and configuring Microk8s and SpinKube.

## Prerequisites

This guide assumes you are running Ubuntu 24.04, and that you have Snap enabled (which is the
default).

> The testing platform for this installation was an Akamai Edge Linode running 4G of memory and 2
> cores.

## Installing Spin

You will need to [install Spin](https://developer.fermyon.com/spin/quickstart). The easiest way is
to just use the following one-liner to get the latest version of Spin:

```console { data-plausible="copy-quick-deploy-sample" }
$ curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash
```

Typically you will then want to move `spin` to `/usr/local/bin` or somewhere else on your `$PATH`:

```console { data-plausible="copy-quick-deploy-sample" }
$ sudo mv spin /usr/local/bin/spin
```

You can test that it's on your `$PATH` with `which spin`. If this returns blank, you will need to
adjust your `$PATH` variable or put Spin somewhere that is already on `$PATH`.

## A Script To Do This

If you would rather work with a shell script, you may find [this
Gist](https://gist.github.com/kate-goldenring/47950ccb30be2fa0180e276e82ac3593#file-spinkube-on-microk8s-sh)
a great place to start. It installs Microk8s and SpinKube, and configures both.

## Installing Microk8s on Ubuntu

Use `snap` to install microk8s:

```console { data-plausible="copy-quick-deploy-sample" }
$ sudo snap install microk8s --classic
```

This will install Microk8s and start it. You may want to read the [official installation
instructions](https://microk8s.io/docs/getting-started) before proceeding. Wait for a moment or two,
and then ensure Microk8s is running with the `microk8s status` command.

Next, enable the TLS certificate manager:

```console { data-plausible="copy-quick-deploy-sample" }
$ microk8s enable cert-manager
```

Now we’re ready to install the SpinKube environment for running Spin applications.

### Installing SpinKube

SpinKube provides the entire toolkit for running Spin serverless apps. You may want to familiarize
yourself with the [SpinKube quickstart](https://www.spinkube.dev/docs/install/quickstart/) guide
before proceeding.

First, we need to apply a runtime class and a CRD for SpinKube:

```console { data-plausible="copy-quick-deploy-sample" }
$ microk8s kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.runtime-class.yaml
$ microk8s kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.crds.yaml
```

Both of these should apply immediately.

We then need to install KWasm because it is not yet included with Microk8s:

```console { data-plausible="copy-quick-deploy-sample" }
$ microk8s helm repo add kwasm http://kwasm.sh/kwasm-operator/
$ microk8s helm install kwasm-operator kwasm/kwasm-operator --namespace kwasm --create-namespace --set kwasmOperator.installerImage=ghcr.io/spinkube/containerd-shim-spin/node-installer:v0.18.0
$ microk8s kubectl annotate node --all kwasm.sh/kwasm-node=true

```

> The last line above tells Microk8s that all nodes on the cluster (which is just one node in this
> case) can run Spin applications.

Next, we need to install SpinKube’s operator using Helm (which is included with Microk8s).

```console { data-plausible="copy-quick-deploy-sample" }
$ microk8s helm install spin-operator --namespace spin-operator --create-namespace --version 0.5.0 --wait oci://ghcr.io/spinframework/charts/spin-operator

```

Now we have the main operator installed. There is just one more step. We need to install the shim
executor, which is a special CRD that allows us to use multiple executors for WebAssembly.

```console { data-plausible="copy-quick-deploy-sample" }
$ microk8s kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.shim-executor.yaml

```

Now SpinKube is installed!

### Running an App in SpinKube

Next, we can run a simple Spin application inside of Microk8s.

While we could write regular deployments or pod specifications, the easiest way to deploy a Spin app
is by creating a simple `SpinApp` resource. Let's use the simple example from SpinKube:

```console { data-plausible="copy-quick-deploy-sample" }
$ microk8s kubectl apply -f https://raw.githubusercontent.com/spinframework/spin-operator/main/config/samples/simple.yaml
```

The above installs a simple `SpinApp` YAML that looks like this:

```yaml
apiVersion: core.spinkube.dev/v1alpha1
kind: SpinApp
metadata:
  name: simple-spinapp
spec:
  image: "ghcr.io/spinkube/containerd-shim-spin/examples/spin-rust-hello:v0.13.0"
  replicas: 1
  executor: containerd-shim-spin
```

You can read up on the definition [in the
documentation](https://www.spinkube.dev/docs/reference/spin-app/).

It may take a moment or two to get started, but you should be able to see the app with `microk8s
kubectl get pods`.

```console { data-plausible="copy-quick-deploy-sample" }
$ microk8s kubectl get po
NAME                              READY   STATUS    RESTARTS   AGE
simple-spinapp-5c7b66f576-9v9fd   1/1     Running   0          45m
```

### Troubleshooting

If `STATUS` gets stuck in `ContainerCreating`, it is possible that KWasm did not install correctly.
Try doing a `microk8s stop`, waiting a few minutes, and then running `microk8s start`. You can also
try the command:

```console { data-plausible="copy-quick-deploy-sample" }
$ microk8s kubectl logs -n kwasm -l app.kubernetes.io/name=kwasm-operator
```

### Testing the Spin App

The easiest way to test our Spin app is to port forward from the Spin app to the outside host:

```console { data-plausible="copy-quick-deploy-sample" }
$ microk8s kubectl port-forward services/simple-spinapp 8080:80
```

You can then run `curl localhost:8080/hello`

```console { data-plausible="copy-quick-deploy-sample" }
$ curl localhost:8080/hello
Hello world from Spin!
```

### Where to go from here

So far, we installed Microk8s, SpinKube, and a single Spin app. To have a more production-ready
version, you might want to:

- Generate TLS certificates and attach them to your Spin app to add HTTPS support. If you are using
  an ingress controller (see below), [here is the documentation for TLS
  config](https://kubernetes.github.io/ingress-nginx/user-guide/tls/).
- Configure a [cluster ingress](https://microk8s.io/docs/addon-ingress)
- Set up another Linode Edge instsance and create a [two-node Microk8s
  cluster](https://microk8s.io/docs/clustering).

### Bonus: Configuring Microk8s ingress

Microk8s includes an NGINX-based ingress controller that works great with Spin applications.

Enable the ingress controller: `microk8s enable ingress`

Now we can create an ingress that routes our traffic to the `simple-spinapp` app. Create the file
`ingress.yaml` with the following content. Note that the [`service.name`](http://service.name) is
the name of our Spin app.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: http-ingress
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: simple-spinapp
                port:
                  number: 80
```

Install the above with `microk8s kubectl -f ingress.yaml`. After a moment or two, you should be able
to run `curl [localhost](http://localhost)` and see `Hello World!`.

## Conclusion

In this guide we've installed Spin, Microk8s, and SpinKube and then run a Spin application.

To learn more about the many things you can do with Spin apps, go to [the Spin developer
docs](https://developer.fermyon.com/spin). You can also look at a variety of examples at [Spin Up
Hub](https://developer.fermyon.com/hub).

Or to try out different Kubernetes configurations, check out [other installation
guides](https://www.spinkube.dev/docs/install/).
