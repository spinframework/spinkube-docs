---
title: External Variable Providers
description: Configure external variable providers for your Spin App.
date: 2024-07-17
categories: [Spin Operator]
tags: [Tutorials]
weight: 12
---

In the [Assigning Variables](./assigning-variables.md) guide, you learned how to configure variables
on the SpinApp via its [variables](../reference/spin-app.md#spinappspecvariablesindex) section,
either by supplying values in-line or via a Kubernetes ConfigMap or Secret.

You can also utilize an external service like [Vault](https://vaultproject.io) or [Azure Key
Vault](https://azure.microsoft.com/en-us/products/key-vault) to provide variable values for your
application. This guide will show you how to use and configure both services in tandem with
corresponding sample applications.

## Prerequisites

To follow along with this tutorial, you'll need:

- A Kubernetes cluster running SpinKube. See the [Installation](../install/_index.md) guides for
  more information.
- The [kubectl CLI](https://kubernetes.io/docs/tasks/tools/#kubectl)
- The [spin CLI](https://developer.fermyon.com/spin/v2/install )
- The [kube plugin for
  Spin](https://github.com/spinframework/spin-plugin-kube?tab=readme-ov-file#install)

## Supported providers

Spin currently supports [Vault](#vault-provider) and [Azure Key Vault](#azure-key-vault-provider) as
external variable providers. Configuration is supplied to the application via a [Runtime
Configuration
file](https://developer.fermyon.com/spin/v2/dynamic-configuration#dynamic-and-runtime-application-configuration).

In SpinKube, this configuration file can be supplied in the form of a Kubernetes secret and linked
to a SpinApp via its
[runtimeConfig.loadFromSecret](https://www.spinkube.dev/docs/reference/spin-app/#spinappspecruntimeconfig)
section.

> Note: `loadFromSecret` takes precedence over any other `runtimeConfig` configuration. Thus, *all*
> runtime configuration must be contained in the Kubernetes secret, including
> [SQLite](../reference/spin-app.md#spinappspecruntimeconfigsqlitedatabasesindex), [Key
> Value](../reference/spin-app.md#spinappspecruntimeconfigkeyvaluestoresindex) and
> [LLM](../reference/spin-app.md#spinappspecruntimeconfigllmcompute) options that might otherwise be
> specified via their dedicated specs.

Let's look at examples utilizing specific provider configuration next.

# Vault provider

[Vault](https://vaultproject.io) is a popular choice for storing secrets and serving as a secure
key-value store.

This guide assumes you have:

- A [Vault cluster](https://www.vaultproject.io/)
- The [vault CLI](https://developer.hashicorp.com/vault/docs/install)

### Build and publish the Spin application

We'll use the [variable explorer
app](https://github.com/spinframework/spin-operator/tree/main/apps/variable-explorer) to test this
integration.

First, clone the repository locally and navigate to the `variable-explorer` directory:

```bash
git clone git@github.com:spinkube/spin-operator.git
cd apps/variable-explorer
```

Now, build and push the application to a registry you have access to. Here we'll use
[ttl.sh](https://ttl.sh):

```bash
spin build
spin registry push ttl.sh/variable-explorer:1h
```

### Create the `runtime-config.toml` file

Here's a sample `runtime-config.toml` file containing Vault provider configuration:

```toml
[[config_provider]]
type = "vault"
url = "https://my-vault-server:8200"
token = "my_token"
mount = "admin/secret"
```

To use this sample, you'll want to update the `url` and `token` fields with values applicable to
your Vault cluster. The `mount` value will depend on the Vault namespace and `kv-v2` secrets engine
name. In this sample, the namespace is `admin` and the engine is named `secret`, eg by running
`vault secrets enable --path=secret kv-v2`.

### Create the secrets in Vault

Create the `log_level`, `platform_name` and `db_password` secrets used by the variable-explorer
application in Vault:

```bash
vault kv put secret/log_level value=INFO
vault kv put secret/platform_name value=Kubernetes
vault kv put secret/db_password value=secret_sauce
```

### Create the SpinApp and Secret

Next, scaffold the SpinApp and Secret resource (containing the `runtime-config.toml` data) together
in one go via the `kube` plugin:

```bash
spin kube scaffold -f ttl.sh/variable-explorer:1h -c runtime-config.toml -o scaffold.yaml
```

### Deploy the application

```bash
kubectl apply -f scaffold.yaml
```

### Test the application

You are now ready to test the application and verify that all variables are passed correctly to the
SpinApp from the Vault provider.

Configure port forwarding from your local machine to the corresponding Kubernetes `Service`:

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

# Azure Key Vault provider

[Azure Key Vault](https://azure.microsoft.com/en-us/products/key-vault) is a secure secret store for
distributed applications hosted on the [Azure](https://azure.microsoft.com) platform.

This guide assumes you have:

- An [Azure account](https://azure.microsoft.com/en-us/free/)
- The [az CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

### Build and publish the Spin application

We'll use the [Azure Key Vault
Provider](https://github.com/fermyon/enterprise-architectures-and-patterns/tree/main/application-variable-providers/azure-key-vault-provider)
sample application for this exercise.

First, clone the repository locally and navigate to the `azure-key-vault-provider` directory:

```bash
git clone git@github.com:fermyon/enterprise-architectures-and-patterns.git
cd enterprise-architectures-and-patterns/application-variable-providers/azure-key-vault-provider
```

Now, build and push the application to a registry you have access to. Here we'll use
[ttl.sh](https://ttl.sh):

```bash
spin build
spin registry push ttl.sh/azure-key-vault-provider:1h
```

The next steps will guide you in creating and configuring an Azure Key Vault and populating the
runtime configuration file with connection credentials.

### Deploy Azure Key Vault

```bash
# Variable Definition
KV_NAME=spinkube-keyvault
LOCATION=westus2
RG_NAME=rg-spinkube-keyvault

# Create Azure Resource Group and Azure Key Vault
az group create -n $RG_NAME -l $LOCATION
az keyvault create -n $KV_NAME \
  -g $RG_NAME \
  -l $LOCATION \
  --enable-rbac-authorization true

# Grab the Azure Resource Identifier of the Azure Key Vault instance
KV_SCOPE=$(az keyvault show -n $KV_NAME -g $RG_NAME -otsv --query "id")
```

### Add a Secret to the Azure Key Vault instance

```bash
# Grab the ID of the currently signed in user in Azure CLI
CURRENT_USER_ID=$(az ad signed-in-user show -otsv --query "id")

# Make the currently signed in user a Key Vault Secrets Officer
# on the scope of the new Azure Key Vault instance
az role assignment create --assignee $CURRENT_USER_ID \
  --role "Key Vault Secrets Officer" \
  --scope $KV_SCOPE

# Create a test secret called 'secret` in the Azure Key Vault instance
az keyvault secret set -n secret --vault-name $KV_NAME --value secret_value -o none
```

### Create a Service Principal and Role Assignment for Spin

```bash
SP_NAME=sp-spinkube-keyvault
SP=$(az ad sp create-for-rbac -n $SP_NAME -ojson)

CLIENT_ID=$(echo $SP | jq -r '.appId')
CLIENT_SECRET=$(echo $SP | jq -r '.password')
TENANT_ID=$(echo $SP | jq -r '.tenant')

az role assignment create --assignee $CLIENT_ID \
  --role "Key Vault Secrets User" \
  --scope $KV_SCOPE
```

### Create the `runtime-config.toml` file

Create a `runtime-config.toml` file with the following contents, substituting in the values for
`KV_NAME`, `CLIENT_ID`, `CLIENT_SECRET` and `TENANT_ID` from the previous steps.

```toml
[[config_provider]]
type = "azure_key_vault"
vault_url = "https://<$KV_NAME>.vault.azure.net/"
client_id = "<$CLIENT_ID>"
client_secret = "<$CLIENT_SECRET>"
tenant_id = "<$TENANT_ID>"
authority_host = "AzurePublicCloud"
```

### Create the SpinApp and Secret

Scaffold the SpinApp and Secret resource (containing the `runtime-config.toml` data) together in one
go via the `kube` plugin:

```bash
spin kube scaffold -f ttl.sh/azure-key-vault-provider:1h -c runtime-config.toml -o scaffold.yaml
```

### Deploy the application

```bash
kubectl apply -f scaffold.yaml
```

### Test the application

Now you are ready to test the application and verify that the secret resolves its value from Azure
Key Vault.

Configure port forwarding from your local machine to the corresponding Kubernetes `Service`:

```bash
kubectl port-forward services/azure-key-vault-provider 8080:80

Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

When port forwarding is established, you can send an HTTP request to the azure-key-vault-provider
app from within an additional terminal session:

```bash
curl http://localhost:8080
Loaded secret from Azure Key Vault: secret_value
```
