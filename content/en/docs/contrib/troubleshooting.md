---
title: Troubleshooting
description: Troubleshooting common errors and issues with SpinKube.
weight: 13
aliases:
  - /docs/spin-operator/support/troubleshooting
---

The following is a list of common error messages and potential troubleshooting suggestions that
might assist you with your work.

## SpinKube Support Policy

SpinKube provides support on a best-effort basis. For users who installed SpinKube manually following the documentation, please report issues in the [Spin Operator repository](https://github.com/spinframework/spin-operator/issues/new). For installations via the Azure Marketplace, please open an issue in the [Azure repository](https://github.com/spinframework/azure/issues/new) for assistance. If your issue is urgent, feel free to raise it in [Slack](https://cloud-native.slack.com/archives/C06PC7JA1EE).

## Failure downloading the Helm chart

While the [Spin Operator Helm chart](https://github.com/spinframework/spin-operator/pkgs/container/charts%2Fspin-operator) is public and can be fetched anonymously, you may run into errors pulling the chart if you've previously authenticated with the ghcr.io registry but the authentication token has since expired.

The error would look something like the following:

```console
helm install spin-operator \
 --namespace spin-operator --create-namespace --version 0.5.0 --wait oci://ghcr.io/spinframework/charts/spin-operator
Error: INSTALLATION FAILED: failed to download "oci://ghcr.io/spinframework/charts/spin-operator" at version "0.5.0"
```

To fix, either re-authenticate with the registry with a valid token (e.g. `docker login ghcr.io`) or log out of the registry and pull the chart anonymously (e.g. `docker logout ghcr.io`).

## No endpoints available for service "spin-operator-webhook-service"

When following the quickstart guide the following error can occur when running the `kubectl apply -f
https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.shim-executor.yaml`
command:

```console
Error from server (InternalError): error when creating "https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.shim-executor.yaml": Internal error occurred: failed calling webhook "mspinappexecutor.kb.io": failed to call webhook: Post "https://spin-operator-webhook-service.spin-operator.svc:443/mutate-core-spinkube-dev-v1alpha1-spinappexecutor?timeout=10s": no endpoints available for service "spin-operator-webhook-service"
```

To address the error above, first look to see if Spin Operator is running:

```console
get pods -n spin-operator
NAME                                                READY   STATUS              RESTARTS   AGE
spin-operator-controller-manager-5bdcdf577f-htshb   0/2     ContainerCreating   0          26m
```

If the above result (ready 0/2) is returned, then use the name from the above result to `kubectl
describe pod` of the spin-operator:

```console
kubectl describe pod spin-operator-controller-manager-5bdcdf577f-htshb -n spin-operator
```

If the above command's response includes the message `SetUp failed for volume "cert" : secret
"webhook-server-cert" not found`, please check the certificate. The spin operator requires this
certificate to serve webhooks, and the missing certificate could be one reason why the spin operator
is failing to start.

The command to check the certificate and the desired output is as follows:

```console
kubectl get certificate -n spin-operator
NAME                         READY   SECRET                AGE
spin-operator-serving-cert   True    webhook-server-cert   11m
```

Instead of the desired output shown above you may be getting the `No resources found in
spin-operator namespace.` response from the command. For example:

```console
kubectl get certificate -n spin-operator
No resources found in spin-operator namespace.
```

To resolve this issue, please try to install the Spin Operator again. Except this time, use the
`helm upgrade --install` syntax instead of just `helm install`:

```console
helm upgrade --install spin-operator \
  --namespace spin-operator \
  --create-namespace \
  --version 0.5.0 \
  --wait \
  oci://ghcr.io/spinframework/charts/spin-operator
```

Once the Spin Operator is installed you can try and run the `kubectl apply -f
https://github.com/spinframework/spin-operator/releases/download/v0.5.0/spin-operator.shim-executor.yaml`
command again. The issue should be resolved now.

## Error Validating Data: Connection Refused

When trying to run the `kubectl apply -f <URL>` command (for example installing the `cert-manager`
etc.) you may encounter an error similar to the following:

```
$ kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.yaml

error: error validating "https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.yaml": error validating data: failed to download openapi: Get "https://127.0.0.1:6443/openapi/v2?timeout=32s": dial tcp 127.0.0.1:6443: connect: connection refused; if you choose to ignore these errors, turn validation off with --validate=false
```

This is because no cluster exists. You can create a cluster following the [Quickstart guide]({{< ref
"quickstart" >}}).

## Installation Failed

When trying to install a new version of a chart you may get the following error:

```console
Error: INSTALLATION FAILED: cannot re-use a name that is still in use
```

For example, if you have installed `v0.14.0` of kwasm-operator using the following `helm install`
command:

```console
helm install \
  kwasm-operator kwasm/kwasm-operator \
  --namespace kwasm \
  --create-namespace \
  --set kwasmOperator.installerImage=ghcr.io/spinkube/containerd-shim-spin/node-installer:v0.14.0
```

Reissuing the above command with the new version `v0.15.0` will result in the following error -
`Error: INSTALLATION FAILED: cannot re-use a name that is still in use`. To use the same command
when installing and upgrading a release, use `upgrade --install` ([as referenced here in the
official Helm
documentation](https://v2.helm.sh/docs/developing_charts/#upgrade-a-release-idempotently)). For
example:

```console
helm upgrade --install \
  kwasm-operator kwasm/kwasm-operator \
  --namespace kwasm \
  --create-namespace \
  --set kwasmOperator.installerImage=ghcr.io/spinframework/containerd-shim-spin/node-installer:v0.19.0
```

## Cluster Already Exists

When trying to create a cluster (e.g. a cluster named `wasm-cluster`) you may receive an error
message similar to the following:

```console
FATA[0000] Failed to create cluster 'wasm-cluster' because a cluster with that name already exists
```

### Cluster Information

With `k3d` installed, you can use the following command to get a cluster list:

```console
$ k3d cluster list
NAME           SERVERS   AGENTS   LOADBALANCER
wasm-cluster   1/1       2/2      true
```

With `kubectl installed, you can use the following command to dump cluster information (this is much
more verbose):

```console
kubectl cluster-info dump
```

### Cluster Delete

With `k3d` installed, you can delete the cluster by name, as shown in the command below:

```console
$ k3d cluster delete wasm-cluster
INFO[0000] Deleting cluster 'wasm-cluster'
INFO[0002] Deleting cluster network 'k3d-wasm-cluster'
INFO[0002] Deleting 1 attached volumes...
INFO[0002] Removing cluster details from default kubeconfig...
INFO[0002] Removing standalone kubeconfig file (if there is one)...
INFO[0002] Successfully deleted cluster wasm-cluster!
```

## Too long: must have at most 262144 bytes

When running `kubectl apply -f my-file.yaml`, the following error can occur if the yaml file is too
large:

```console
Too long: must have at most 262144 bytes
```

Using the `--server-side=true` option resolves this issue:

```console
kubectl apply --server-side=true -f my-file.yaml
```

## Redis Operator

Noted an error when installing Redis Operator:

```console
$ helm repo add redis-operator https://spotahome.github.io/redis-operator
"redis-operator" has been added to your repositories
$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "redis-operator" chart repository
Update Complete. ⎈Happy Helming!⎈
$ helm install redis-operator redis-operator/redis-operator
Error: INSTALLATION FAILED: failed to install CRD crds/databases.spotahome.com_redisfailovers.yaml: error parsing : error converting YAML to JSON: yaml: line 4: did not find expected node content
```

Used the following commands to enforce using a different version of Redis Operator (whilst waiting
on [this PR fix](https://github.com/spotahome/redis-operator/pull/685) to be merged).

```console
$ helm install redis-operator redis-operator/redis-operator --version 3.2.9
NAME: redis-operator
LAST DEPLOYED: Mon Jan 22 12:33:54 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

## error: requires go version

When building apps like the
[cpu-load-gen](https://github.com/spinframework/spin-operator/tree/main/apps/cpu-load-gen) Spin app, you
may get the following error if your TinyGo is not up to date. The error requires go version `1.18`
through `1.20` but this is not necessarily the case. It **is** recommended that you have the latest
go installed e.g. `1.21` and downgrading is unnecessary. Instead please go ahead and [install the
latest version of TinyGo](https://tinygo.org/) to resolve this error:

```console
user@user:~/spin-operator/apps/cpu-load-gen$ spin build
Building component cpu-load-gen with `tinygo build -target=wasi -gc=leaking -no-debug -o main.wasm main.go`
error: requires go version 1.18 through 1.20, got go1.21
```
