---
title: Glossary
description: Glossary of terms used by the SpinKube project.
weight: 100
categories: [SpinKube]
---

The following glossary of terms is in the context of deploying, scaling, automating and managing
Spin applications in containerized environments.

## Chart

A Helm chart is a package format used in Kubernetes for deploying applications. It contains all the
necessary files, configurations, and dependencies required to deploy and manage an application on a
Kubernetes cluster. Helm charts provide a convenient way to define, install, and upgrade complex
applications in a consistent and reproducible manner.

## Cluster

A Kubernetes cluster is a group of nodes (servers) that work together to run containerized
applications. It consists of a control plane and worker nodes. The control plane manages and
orchestrates the cluster, while the worker nodes host the containers. The control plane includes
components like the API server, scheduler, and controller manager. The worker nodes run the
containers using container runtime engines like Docker. Kubernetes clusters provide scalability,
high availability, and automated management of containerized applications in a distributed
environment.

## Container Runtime

A container runtime is a software that manages the execution of containers. It is responsible for
starting, stopping, and managing the lifecycle of containers. Container runtimes interact with the
underlying operating system to provide isolation and resource management for containers. They also
handle networking, storage, and security aspects of containerization. Popular container runtimes
include Docker, containerd, and CRI-O. They enable the deployment and management of containerized
applications, allowing developers to package their applications with all the necessary dependencies
and run them consistently across different environments.

## Controller

A Controller is a core component responsible for managing the desired state of a specific resource
or set of resources. It continuously monitors the cluster and takes actions to ensure that the
actual state matches the desired state. Controllers handle tasks such as creating, updating, and
deleting resources, as well as reconciling any discrepancies between the current and desired states.
They provide automation and self-healing capabilities, ensuring that the cluster remains in the
desired state even in the presence of failures or changes. Controllers play a crucial role in
maintaining the stability and reliability of Kubernetes deployments.

## Custom Resource (CR)

In the context of Kubernetes, a Custom Resource (CR) is an extension mechanism that allows users to
define and manage their own API resources. It enables the creation of new resource types that are
specific to an application or workload. Custom Resources are defined using Custom Resource
Definitions (CRDs) and can be treated and managed like any other Kubernetes resource. They provide a
way to extend the Kubernetes API and enable the development of custom controllers to handle the
lifecycle and behavior of these resources. Custom Resources allow for greater flexibility and
customization in Kubernetes deployments.

## Custom Resource Definition (CRD)

A Custom Resource Definition (CRD) is an extension mechanism that allows users to define their own
custom resources. It enables the creation of new resource types with specific schemas and behaviors.
CRDs define the structure and validation rules for custom resources, allowing users to store and
manage additional information beyond the built-in Kubernetes resources. Once a CRD is created,
instances of the custom resource can be created, updated, and deleted using the Kubernetes API. CRDs
provide a way to extend Kubernetes and tailor it to specific application requirements.

## SpinApp CRD

The SpinApp CRD is a Kubernetes resource that extends the functionality of the Kubernetes API to
support Spin applications. It defines a custom resource called "SpinApp" that encapsulates all the
necessary information to deploy and manage a Spin application within a Kubernetes cluster. The
SpinApp CRD consists of several key fields that define the desired state of a Spin application.

Here's an example of a SpinApp custom resource that uses the SpinApp CRD schema:

```yaml
apiVersion: core.spinkube.dev/v1alpha1
kind: SpinApp
metadata:
  name: simple-spinapp
spec:
  image: "ghcr.io/spinframework/containerd-shim-spin/examples/spin-rust-hello:v0.19.0"
  replicas: 1
  executor: "containerd-shim-spin"
```

> SpinApp CRDs are kept separate from Helm. If using Helm, CustomResourceDefinition (CRD) resources
> must be installed prior to installing the Helm chart.

You can modify the example above to customize the SpinApp via a YAML file. Here's an updated YAML
file with additional customization options:

```yaml
apiVersion: core.spinkube.dev/v1alpha1
kind: SpinApp
metadata:
  name: simple-spinapp
spec:
  image: 'ghcr.io/spinframework/containerd-shim-spin/examples/spin-rust-hello:v0.19.0'
  replicas: 3
  imagePullSecrets:
    - name: spin-image-secret
  serviceAnnotations:
    key: value
  podAnnotations:
    key: value
  resources:
    limits:
      cpu: '1'
      memory: 512Mi
    requests:
      cpu: '0.5'
      memory: 256Mi
  env:
    - name: ENV_VAR1
      value: value1
    - name: ENV_VAR2
      value: value2
  # Add any other user-defined values here
```

In this updated example, we have added additional customization options:

- `imagePullSecrets`: An optional field that lets you reference a Kubernetes secret that has
  credentials for you to pull in images from a private registry.
- `serviceAnnotations`: An optional field that lets you set specific annotations on the underlying
  service that is created.
- `podAnnotations`: An optional field that lets you set specific annotations on the underlying pods
  that are created.
- `resources`: You can specify resource limits and requests for CPU and memory. Adjust the values
  according to your application's resource requirements.
- `env`: You can define environment variables for your SpinApp. Add as many environment variables as
  needed, providing the name and value for each.

To apply the changes, save the YAML file (e.g. `updated-spinapp.yaml`) and then apply it to your
Kubernetes cluster using the following command:

```bash
kubectl apply -f updated-spinapp.yaml
```

## Helm

Helm is a package manager for Kubernetes that simplifies the deployment and management of
applications. It uses charts, which are pre-configured templates, to define the structure and
configuration of an application. Helm allows users to easily install, upgrade, and uninstall
applications on a Kubernetes cluster. It also supports versioning, dependency management, and
customization of deployments. Helm charts can be shared and reused, making it a convenient tool for
managing complex applications in a Kubernetes environment.

## Image

In the context of Kubernetes, an image refers to a packaged and executable software artifact that
contains all the necessary dependencies and configurations to run a specific application or service.
It is typically built from a Dockerfile and stored in a container registry. Images are used as the
basis for creating containers, which are lightweight and isolated runtime environments. Kubernetes
pulls the required images from the registry and deploys them onto the cluster's worker nodes. Images
play a crucial role in ensuring consistent and reproducible deployments of applications in
Kubernetes.

## Kubernetes

Kubernetes is an open-source container orchestration platform that automates the deployment,
scaling, and management of containerized applications. It provides a framework for running and
coordinating containers across a cluster of nodes. Kubernetes abstracts the underlying
infrastructure and provides features like load balancing, service discovery, and self-healing
capabilities. It enables organizations to efficiently manage and scale their applications, ensuring
high availability and resilience.

## Open Container Initiative (OCI)

The Open Container Initiative (OCI) is an open governance structure and project that aims to create
industry standards for container formats and runtime. It was formed to ensure compatibility and
interoperability between different container technologies. OCI defines specifications for container
images and runtime, which are used by container runtimes like Docker and containerd. These
specifications provide a common framework for packaging and running containers, allowing users to
build and distribute container images that can be executed on any OCI-compliant runtime. OCI plays a
crucial role in promoting portability and standardization in the container ecosystem.

## Pod

A Pod is the smallest and most basic unit of deployment. It represents a single instance of a
running process in a cluster. A Pod can contain one or more containers that are tightly coupled and
share the same resources, such as network and storage. Containers within a Pod are scheduled and
deployed together on the same node. Pods are ephemeral and can be created, deleted, or replaced
dynamically. They provide a way to encapsulate and manage the lifecycle of containerized
applications in Kubernetes.

## Role Based Access Control (RBAC)

Role-Based Access Control (RBAC) is a security mechanism in Kubernetes that provides fine-grained
control over access to cluster resources. RBAC allows administrators to define roles and permissions
for users or groups, granting or restricting access to specific operations and resources within the
cluster. RBAC ensures that only authorized users can perform certain actions, helping to enforce
security policies and prevent unauthorized access to sensitive resources. It enhances the overall
security and governance of Kubernetes clusters.

## Runtime Class

A Runtime Class is a resource that allows users to specify different container runtimes for running
their workloads. It provides a way to define and select the runtime environment in which a Pod
should be executed. By using Runtime Classes, users can choose between different container runtimes,
based on their specific requirements. This flexibility enables the deployment of workloads with
different runtime characteristics, allowing for better resource utilization and performance
optimization in Kubernetes clusters.

## Scheduler

A scheduler is a component responsible for assigning Pods to nodes in the cluster. It takes into
account factors like resource availability, node capacity, and any defined scheduling constraints or
policies. The scheduler ensures that Pods are placed on suitable nodes to optimize resource
utilization and maintain high availability. It considers factors such as affinity, anti-affinity,
and resource requirements when making scheduling decisions. The scheduler continuously monitors the
cluster and makes adjustments as needed to maintain the desired state of the workload distribution.

## Service

In Kubernetes, a Service is an abstraction that defines a logical set of Pods that enables clients
to interact with a consistent set of Pods, regardless of whether the code is designed for a
cloud-native environment or a containerized legacy application.

## Spin

[Spin](https://developer.fermyon.com/spin/v2/) is a framework designed for building and running event-driven microservice applications using
WebAssembly (Wasm) components.

## `SpinApp` Manifest

The goal of the `SpinApp` manifest is twofold:

- to represent the possible options for configuring a Wasm workload running in Kubernetes
- to simplify and abstract the internals of _how_ that Wasm workload is executed, while allowing the
  user to configure it to their needs

As a result, the simplest `SpinApp` manifest only requires the registry reference to create a
deployment, pod, and service with the right Wasm executor.

However, the `SpinApp` manifest currently supports configuring options such as:

- image pull secrets to fetch applications from private registries
- liveness and readiness probes
- resource limits (and requests\*)
- Spin variables
- volume mounts
- autoscaling

## Spin App Executor (CRD)

The `SpinAppExecutor` CRD is a [Custom Resource Definition](#custom-resource-definition-crd)
utilized by Spin Operator to determine which executor type should be used in running a SpinApp.

## Spin Operator

Spin Operator is a Kubernetes operator in charge of handling the lifecycle of Spin applications
based on their SpinApp resources.
