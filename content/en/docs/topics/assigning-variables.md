---
title: Assigning variables
description: Configure Spin Apps using values from Kubernetes ConfigMaps and Secrets.
date: 2024-02-16
categories: [Spin Operator]
tags: [Tutorials]
weight: 11
aliases:
- /docs/spin-operator/tutorials/assigning-variables
---


By using variables, you can alter application behavior without recompiling your SpinApp. When
running in Kubernetes, you can either provide constant values for variables, or reference them from
Kubernetes primitives such as `ConfigMaps` and `Secrets`. This tutorial guides your through the
process of assigning variables to your `SpinApp`.

> Note: If you'd like to learn how to configure your application with an external variable provider
> like [Vault](https://vaultproject.io) or [Azure Key
> Vault](https://azure.microsoft.com/en-us/products/key-vault), see the [External Variable Provider
> guide](./external-variable-providers.md)

## Build and Store SpinApp in an OCI Registry

We’re going to build the SpinApp and store it inside of a [ttl.sh](http://ttl.sh) registry. Move
into the
[apps/variable-explorer](https://github.com/spinframework/spin-operator/blob/main/apps/variable-explorer)
directory and build the SpinApp we’ve provided:

```bash
# Build and publish the sample app
cd apps/variable-explorer
spin build
spin registry push ttl.sh/variable-explorer:1h
```

Note that the tag at the end of [ttl.sh/variable-explorer:1h](http://ttl.sh/variable-explorer:1h)
indicates how long the image will last e.g. `1h` (1 hour). The maximum is `24h` and you will need to
repush if ttl exceeds 24 hours.

For demonstration purposes, we use the [variable
explorer](https://github.com/spinframework/spin-operator/blob/main/apps/variable-explorer) sample app. It
reads three different variables (`log_level`, `platform_name` and `db_password`) and prints their
values to the `STDOUT` stream as shown in the following snippet:

```rust
let log_level = variables::get("log_level")?;
let platform_name = variables::get("platform_name")?;
let db_password = variables::get("db_password")?;

println!("# Log Level: {}", log_level);
println!("# Platform name: {}", platform_name);
println!("# DB Password: {}", db_password);
```

Those variables are defined as part of the Spin manifest (`spin.toml`), and access to them is
granted to the `variable-explorer` component:

```toml
[variables]
log_level = { default = "WARN" }
platform_name = { default = "Fermyon Cloud" }
db_password = { required = true }

[component.variable-explorer.variables]
log_level = "{{ log_level }}"
platform_name = "{{ platform_name }}"
db_password = "{{ db_password }}"
```

For further reading on defining variables in the Spin manifest, see the [Spin Application Manifest
Reference](https://developer.fermyon.com/spin/v2/manifest-reference#the-variables-table).

## Configuration data in Kubernetes

In Kubernetes, you use `ConfigMaps` for storing non-sensitive, and `Secrets` for storing sensitive
configuration data. The deployment manifest (`config/samples/variable-explorer.yaml`) contains
specifications for both a `ConfigMap` and a `Secret`:

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: spinapp-cfg
data:
  logLevel: INFO
---
kind: Secret
apiVersion: v1
metadata:
  name: spinapp-secret
data:
  password: c2VjcmV0X3NhdWNlCg==
```

## Assigning variables to a SpinApp

When creating a `SpinApp`, you can choose from different approaches for specifying variables:

1. Providing constant values
2. Loading configuration values from ConfigMaps
3. Loading configuration values from Secrets

The `SpinApp` specification contains the `variables` array, that you use for specifying variables
(See `kubectl explain spinapp.spec.variables`).

The deployment manifest (`config/samples/variable-explorer.yaml`) specifies a static value for
`platform_name`. The value of `log_level` is read from the `ConfigMap` called `spinapp-cfg`, and the
`db_password` is read from the `Secret` called `spinapp-secret`:

```yaml
kind: SpinApp
apiVersion: core.spinkube.dev/v1alpha1
metadata:
  name: variable-explorer
spec:
  replicas: 1
  image: ttl.sh/variable-explorer:1h
  executor: containerd-shim-spin
  variables:
    - name: platform_name
      value: Kubernetes
    - name: log_level
      valueFrom:
        configMapKeyRef:
          name: spinapp-cfg
          key: logLevel
          optional: true
    - name: db_password
      valueFrom:
        secretKeyRef:
          name: spinapp-secret
          key: password
          optional: false
```

As the deployment manifest outlines, you can use the `optional` property - as you would do when
specifying environment variables for a regular Kubernetes `Pod` - to control if Kubernetes should
prevent starting the SpinApp, if the referenced configuration source does not exist.

You can deploy all resources by executing the following command:

```bash
kubectl apply -f config/samples/variable-explorer.yaml

configmap/spinapp-cfg created
secret/spinapp-secret created
spinapp.core.spinkube.dev/variable-explorer created
```

## Inspecting runtime logs of your SpinApp

To verify that all variables are passed correctly to the SpinApp, you can configure port forwarding
from your local machine to the corresponding Kubernetes `Service`:

```bash
kubectl port-forward services/variable-explorer 8080:80

Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

When port forwarding is established, you can send an HTTP request to the variable-explorer from
within an additional terminal session:

```bash
curl http://localhost:8080
Hello from Kubernetes
```

Finally, you can use `kubectl logs` to see all logs produced by the variable-explorer at runtime:

```bash
kubectl logs -l core.spinkube.dev/app-name=variable-explorer

# Log Level: INFO
# Platform Name: Kubernetes
# DB Password: secret_sauce
```
