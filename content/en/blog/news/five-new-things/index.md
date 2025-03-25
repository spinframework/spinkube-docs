---
date: 2024-11-12
title: Five New Things in SpinKube
linkTitle: Five New Things in SpinKube
description: >
  Catching up on what's new in SpinKube
author: The SpinKube Team ([@SpinKube](https://mastodon.social/@SpinKube))
resources:
  - src: "**.{png,jpg}"
    title: "Image #:counter"
---

Since we publicly [released](/blog/2024/03/13/introducing-spinkube/) SpinKube in March we've been hard at work steadily making it better. Spin Operator [`v0.4.0`](https://github.com/spinframework/spin-operator/releases/tag/v0.4.0), Containerd shim for Spin [`v0.17.0`](https://github.com/spinframework/containerd-shim-spin/releases/tag/v0.17.0), and `spin kube` plugin [`v0.3.0`](https://github.com/spinframework/spin-plugin-kube/releases/tag/v0.3.0) have all just been released. To celebrate that, here's five new things in SpinKube you should know about.

## Selective Deployments

SpinKube now supports selectively deploying a subset of a Spin apps components. Consider this simple example Spin application (named salutation in the [example repo](https://github.com/spinframework/spin-operator/tree/main/apps/salutations)) composed of two HTTP-triggered components: `hello` and `goodbye`. In the newly added `components` field you can select which components you would like to be a part of the deployment. Here's an example of what the YAML for a selectively deployed app might look like:

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

We're really excited about this feature because it makes developing microservices easier. Locally develop your application in one code base. Then, when you go to production, you can split your app based on the characteristics of each component. For example you run your front end closer to the end user while keeping your backend colocated with your database.

If you want to learn more about how to use selective deployments in SpinKube checkout this [tutorial](https://www.spinkube.dev/docs/topics/selective-deployments/).

## OpenTelemetry Support

Spin has had [OpenTelemetry](https://opentelemetry.io/) support for a while now, and it's now available in SpinKube. OpenTelemetry is an observability standard that makes understanding your applications running production much easier via traces and metrics.

To configure a `SpinApp` to send telemetry data to an OpenTelemetry collector you need to modify the `SpinAppExecutor` custom resource.

```yaml
apiVersion: core.spinkube.dev/v1alpha1
kind: SpinAppExecutor
metadata:
  name: otel-shim-executor
spec:
  createDeployment: true
  deploymentConfig:
    runtimeClassName: wasmtime-spin-v2
    installDefaultCACerts: true
    otel:
      exporter_otlp_endpoint: http://otel-collector.default.svc.cluster.local:4318
```

Now any Spin apps using this executor will send telemetry to the collector at `otel-collector.default.svc.cluster.local:4318`. For full details on how to use OpenTelemetry in SpinKube checkout this [tutorial](/docs/topics/monitoring-your-app).

![OpenTelemetry](/otel.png)

## MQTT Trigger Support

The Containerd Shim for Spin has added support for [MQTT triggers](https://github.com/spinframework/spin-trigger-mqtt). [MQTT](https://mqtt.org/) is a lightweight, publish-subscribe messaging protocol that enables devices to send and receive messages through a broker. It's used all over the place to enable Internet of Things (IoT) designs.

If you want to learn more about how to use this new trigger checkout this [blog post](https://www.fermyon.com/blog/mqtt_trigger_spinkube) by Kate Goldenring.

## Spintainer Executor

In SpinKube there is a concept of an executor. An executor is defined by the `SpinAppExecutor` CRD and it configures how a `SpinApp` is run. Typically you'll want to define an executor that uses the Containerd shim for Spin.

```yaml
apiVersion: core.spinkube.dev/v1alpha1
kind: SpinAppExecutor
metadata:
  name: containerd-shim-spin
spec:
  createDeployment: true
  deploymentConfig:
    runtimeClassName: wasmtime-spin-v2
    installDefaultCACerts: true
```

However, it can also be useful to run your Spin application directly in a container. You might want to:

- Use a specific version of Spin.
- Use a custom trigger or plugin.
- Workaround a lack of cluster permissions to install the shim.

This is enabled by the new executor we've dubbed 'Spintainer'.

```yaml
apiVersion: core.spinkube.dev/v1alpha1
kind: SpinAppExecutor
metadata:
  name: spintainer
spec:
  createDeployment: true
  deploymentConfig:
    installDefaultCACerts: true
    spinImage: ghcr.io/fermyon/spin:v3.0.0
```

Learn more about the Spintainer executor [here](/docs/misc/spintainer-executor).

## Gaining Stability

SpinKube and its constituent sub-projects are all still in alpha as we iron out the kinks. However, SpinKube has made great leaps and bounds in improving its stability and polish. In the number of releases we've cut for each sub-project we've squashed many bugs and sanded down plenty of rough edges.

One more example of SpinKube's growing stability is the domain migration we've completed in Spin Operator. As of the `v0.4.0` release we have migrated the Spin Operator CRDs from the `spinoperator.dev` domain to `spinkube.dev`[^1]. This change was made to better align the Spin Operator with the overall SpinKube project. While this is a breaking change (upgrade steps can be found [here](/docs/misc/upgrading-to-v0.4.0/)) we're now in a better position to support this domain going forward. This is just one step towards SpinKube eventually moving out of alpha.

## More To Come

We hope this has gotten you as excited about SpinKube as we are. Stay tuned as we continue to make SpinKube better. If you'd like to get involved in the community we'd love to have you — check out our [community page](https://www.spinkube.dev/community/).

[^1]: This was also a great opportunity to exercise the [SKIP](https://github.com/spinframework/skips/tree/main/proposals/004-crd-domains) (SpinKube Improvement Proposal) process.
