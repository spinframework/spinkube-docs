---
title: Installing on Linode Kubernetes Engine (LKE)
description: This guide walks you through the process of installing SpinKube on [LKE](https://www.linode.com/docs/products/compute/kubernetes/).
date: 2024-07-23
tags: [Installation]
---

This guide walks through the process of installing and configuring SpinKube on Linode Kubernetes
Engine (LKE).

## Prerequisites

This guide assumes that you have an [Akamai Linode](https://login.linode.com/) account that is
configured and has sufficient permissions for creating a new LKE cluster.

You will also need recent versions of `kubectl` and `helm` installed on your system.

## Creating an LKE Cluster

LKE has a managed control plane, so you only need to create the pool of worker nodes. In this
tutorial, we will create a 2-node LKE cluster using the smallest available worker nodes. This should
be fine for installing SpinKube and running up to around 100 Spin apps.

You may prefer to run a larger cluster if you plan on mixing containers and Spin apps, because
containers consume substantially more resources than Spin apps do.

In the Linode web console, click on `Kubernetes` in the right-hand navigation, and then click
`Create Cluster`.

![LKE Creation Screen Described Below](../lke-spinkube-create.png)

You will only need to make a few choices on this screen. Here's what we have done:

* **Cluster name**: We named the cluster `spinkube-lke-1`. You should name it according to whatever
  convention you prefer.
* **Region**: We chose the `Chicago, IL (us-ord)` region, but you can choose any region you prefer.
* **Kubernetes Version**: The latest supported Kubernetes version is `1.30`, so we chose that.
* **High Availability Control Plane**: For this testing cluster, we chose `No` on `HA Control Plane`
  because we do not need high availability.
* **Node Pool configuration**: In `Add Node Pools`, we added two `Dedicated 4 GB` simply to show a
  cluster running more than one node. Two nodes is sufficient for Spin apps, though you may prefer
  the more traditional 3 node cluster. Click `Add` to add these, and ignore the warning about
  minimum sizes.

Once you have set things to your liking, click `Create Cluster`.

This will take you to a screen that shows the status of the cluster. Initially, you will want to
wait for all of your `Node Pool` to start up. Once all of the nodes are online, download the
`kubeconfig` file, which will be named something like `spinkube-lke-1-kubeconfig.yaml`.

> The `kubeconfig` file will have the credentials for connecting to your new LKE cluster. Do not
> share that file or put it in a public place.

For all of the subsequent operations, you will want to use the `spinkube-lke-1-kubeconfig.yaml` as
your main Kubernetes configuration file. The best way to do that is to set the environment variable
`KUBECONFIG` to point to that file:

```console
$ export KUBECONFIG=/path/to/spinkube-lke-1-kubeconfig.yaml
```

You can test this using the command `kubectl config view`:

```
$ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://REDACTED.us-ord-1.linodelke.net:443
  name: lke203785
contexts:
- context:
    cluster: lke203785
    namespace: default
    user: lke203785-admin
  name: lke203785-ctx
current-context: lke203785-ctx
kind: Config
preferences: {}
users:
- name: lke203785-admin
  user:
    token: REDACTED
```

This shows us our cluster config. You should be able to cross-reference the `lkeNNNNNN` version with
what you see on your Akamai Linode dashboard.

## Install SpinKube Using Helm

At this point, [install SpinKube with Helm](installing-with-helm). As long as your `KUBECONFIG`
environment variable is pointed at the correct cluster, the installation method documented there
will work.

Once you are done following the installation steps, return here to install a first app.

## Creating a First App

We will use the `spin kube` plugin to scaffold out a new app. If you run the following command and
the `kube` plugin is not installed, you will first be prompted to install the plugin. Choose `yes`
to install.

We'll point to an existing Spin app, a [Hello World program written in
Rust](https://github.com/fermyon/spin/tree/main/examples/http-rust), compiled to Wasm, and stored in
GitHub Container Registry (GHCR):

```console
$ spin kube scaffold --from ghcr.io/spinkube/containerd-shim-spin/examples/spin-rust-hello:v0.13.0 > hello-world.yaml
```

> Note that Spin apps, which are WebAssembly, can be [stored in most container
> registries](https://developer.fermyon.com/spin/v2/registry-tutorial) even though they are not
> Docker containers.

This will write the following to `hello-world.yaml`:

```yaml
apiVersion: core.spinkube.dev/v1alpha1
kind: SpinApp
metadata:
  name: spin-rust-hello
spec:
  image: "ghcr.io/spinkube/containerd-shim-spin/examples/spin-rust-hello:v0.13.0"
  executor: containerd-shim-spin
  replicas: 2
```

Using `kubectl apply`, we can deploy that app:

```console
$ kubectl apply -f hello-world.yaml
spinapp.core.spinkube.dev/spin-rust-hello created
```

With SpinKube, SpinApps will be deployed as `Pod` resources, so we can see the app using `kubectl
get pods`:

```console
$ kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
spin-rust-hello-f6d8fc894-7pq7k   1/1     Running   0          54s
spin-rust-hello-f6d8fc894-vmsgh   1/1     Running   0          54s
```

Status is listed as `Running`, which means our app is ready.

## Making An App Public with a NodeBalancer

By default, Spin apps will be deployed with an internal service. But with Linode, you can provision
a [NodeBalancer](https://www.linode.com/docs/products/networking/nodebalancers/) using a `Service`
object. Here is a `hello-world-service.yaml` that provisions a `nodebalancer` for us:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: spin-rust-hello-nodebalancer
  annotations:
    service.beta.kubernetes.io/linode-loadbalancer-throttle: "4"
  labels:
    core.spinkube.dev/app-name: spin-rust-hello
spec:
  type: LoadBalancer
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    core.spinkube.dev/app.spin-rust-hello.status: ready
  sessionAffinity: None
```

When LKE receives a `Service` whose `type` is `LoadBalancer`, it will provision a NodeBalancer for
you.

> You can customize this for your app simply by replacing all instances of `spin-rust-hello` with
> the name of your app.

We can create the NodeBalancer by running `kubectl apply` on the above file:

```console
$ kubectl apply -f hello-world-nodebalancer.yaml
service/spin-rust-hello-nodebalancer created
```

Provisioning the new NodeBalancer may take a few moments, but we can get the IP address using
`kubectl get service spin-rust-hello-nodebalancer`:

```console
$ get service spin-rust-hello-nodebalancer
NAME                           TYPE           CLUSTER-IP       EXTERNAL-IP       PORT(S)        AGE
spin-rust-hello-nodebalancer   LoadBalancer   10.128.235.253   172.234.210.123   80:31083/TCP   40s
```

The `EXTERNAL-IP` field tells us what the NodeBalancer is using as a public IP. We can now test this
out over the Internet using `curl` or by entering the URL `http://172.234.210.123/hello` into your
browser.

```console
$ curl 172.234.210.123/hello
Hello world from Spin!
```

## Deleting Our App

To delete this sample app, we will first delete the NodeBalancer, and then delete the app:

```console
$ kubectl delete service spin-rust-hello-nodebalancer
service "spin-rust-hello-nodebalancer" deleted
$ kubectl delete spinapp spin-rust-hello
spinapp.core.spinkube.dev "spin-rust-hello" deleted
```

> If you delete the NodeBalancer out of the Linode console, it will not automatically delete the
> `Service` record in Kubernetes, which will cause inconsistencies. So it is best to use `kubectl
> delete service` to delete your NodeBalancer.

If you are also done with your LKE cluster, the easiest way to delete it is to log into the Akamai
Linode dashboard, navigate to `Kubernetes`, and press the `Delete` button. This will destroy all of
your worker nodes and deprovision the control plane.
