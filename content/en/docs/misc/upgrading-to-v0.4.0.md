---
title: Upgrading to v0.4.0
description: Instructions on how to navigate the breaking changes v0.4.0 introduces.
categories: [Spin Operator]
tags: []
---

Spin Operator v0.4.0 introduces a breaking API change. The SpinApp and SpinAppExecutor are moving from the `spinoperator.dev` to `spinkube.dev` domains. This is a breaking change and therefore requires a re-install of the Spin Operator when upgrading to v0.4.0.

## Migration steps

1. Uninstall any existing SpinApps.

   > Note: Back em' up! TODO
   >
   > ```sh
   > kubectl get spinapps.core.spinoperator.dev -o yaml > spinapps.yaml
   > ```

   ```sh
   kubectl delete spinapp.core.spinoperator.dev --all
   ```

2. Uninstall any existing SpinAppExecutors.
   ```sh
   kubectl delete spinappexecutor.core.spinoperator.dev --all
   ```
3. Uninstall the old Spin Operator.
   > Note: If you used a different release name or namespace when installing the Spin Operator you'll have to adjust the command accordingly. Alternatively, if you used something other than Helm to install the Spin Operator, you'll need to uninstall it following whatever approach you used to install it.
   ```sh
   helm uninstall spin-operator --namespace spin-operator
   ```
4. Uninstall the old CRDs.
   ```sh
   kubectl delete crd spinapps.core.spinoperator.dev
   kubectl delete crd spinappexecutors.core.spinoperator.dev
   ```
5. Modify your SpinApps to use the new `apiVersion`.
   Now you'll need to modify the `apiVersion` in your SpinApps, replacing `core.spinoperator.dev/v1alpha1` with `core.spinkube.dev/v1alpha1`.
   > Note: If you don't have your SpinApps tracked in source code somewhere than you will have backed up the SpinApps in your cluster to a file named `spinapps.yaml` in step 1. If you did this then you need to replace the `apiVersion` in the `spinapps.yaml` file. Here's a command that can help with that:
   ```sh
   sed 's|apiVersion: core.spinoperator.dev/v1alpha1|apiVersion: core.spinkube.dev/v1alpha1|g' spinapps.yaml > modified-spinapps.yaml
   ```
6. Install the new CRDs.
   ```sh
   kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.4.0/spin-operator.crds.yaml
   ```
7. Re-install the SpinAppExecutor.
   ```sh
   kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.4.0/spin-operator.shim-executor.yaml
   ```
   If you had other executors you'll need to install them too.
8. Install the new Spin Operator.
   ```sh
   # Install Spin Operator with Helm
   helm install spin-operator \
   --namespace spin-operator \
   --create-namespace \
   --version 0.4.0 \
   --wait \
   oci://ghcr.io/spinkube/charts/spin-operator
   ```
9. Re-apply your modified SpinApps.
   Follow whatever pattern you normally follow to get your SpinApps in the cluster e.g. Kubectl, Flux, Helm, etc.
   > Note: If you backed up your SpinApps in step 1, you can re-apply them using the command below:
   >
   > ```sh
   > kubectl apply -f modified-spinapps.yaml
   > ```
10. Upgrade your `spin kube` plugin.
    If you're using the `spin kube` plugin you'll need to upgrade it to the new version so that the scaffolded apps are still valid.
    ```sh
    spin plugins upgrade kube
    ```
