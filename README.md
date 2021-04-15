# GitOps Workflow with Flux v2 - Multi-Tenancy

[![test](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/test.yaml/badge.svg)](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/test.yaml)
[![e2e](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/e2e.yaml/badge.svg)](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/e2e.yaml)

_For the original example see [flux2-multi-tenancy](https://github.com/fluxcd/flux2-multi-tenancy)._


# Scenario

For this example we assume a scenario with two clusters: staging and production, both having multiple regions each. The
end goal is to leverage Flux and Kustomize to manage both clusters while minimizing duplicated declarations.

## Prerequisites

You will need a Kubernetes cluster version 1.16 or newer and kubectl version 1.18. For a quick local test, you can
use [Kubernetes kind](https://kind.sigs.k8s.io/docs/user/quick-start/) or
[k3d](https://k3d.io/#installation). Any other Kubernetes setup will work as well though.

In order to follow the guide you'll need a GitHub account and a
[personal access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line)
that can create repositories (check all permissions under `repo`).

Install the Flux CLI on MacOS and Linux using Homebrew:

```sh
brew install flux
```

Or install the CLI by downloading precompiled binaries using a Bash script:

```sh
curl -s https://toolkit.fluxcd.io/install.sh | sudo bash
```

## Repository structure

The Git repository contains the following top directories:

- **clusters/** dir contains Helm releases with a custom configuration per cluster
- **clusters** dir contains the Flux configuration per cluster

```
├── clusters
│   ├── production
│   │   ├── northeurope
│   │   │   └── flux-system
│   │   └── westeurope
│   │       └── flux-system
│   └── staging
│       ├── northeurope
│       │   └── flux-system
│       └── westeurope
│           └── flux-system
├── operations
│   ├── production
│   │   ├── northeurope
│   │   └── westeurope
│   └── staging
│       ├── northeurope
│       └── westeurope
└── tenants
    ├── production
    │   ├── northeurope
    │   │   ├── tenant-core.yaml
    │   │   └── tenant-data.yaml
    │   └── westeurope
    │       ├── tenant-core.yaml
    │       └── tenant-data.yaml
    └── staging
        ├── northeurope
        │   ├── tenant-core.yaml
        │   └── tenant-data.yaml
        └── westeurope
            ├── tenant-core.yaml
            └── tenant-data.yaml
        
```

The clusters' configuration is structured into:

- **clusters/production/** dir contains the production Helm release values
- **clusters/staging/** dir contains the staging values

---
# Bootstrap 

## 1. Bootstrap gitops repo, staging environament, north europe region
```bash
k3d cluster create -p 8080:80@loadbalancer --agents 4 --k3s-server-arg "--no-deploy=traefik"

export GITHUB_TOKEN=<REDACTED>
export GITHUB_USER=<YOUR_GITHUB_USER>
export GITHUB_REPO=gitops-demo-multitenant

flux bootstrap github \
--components-extra=image-reflector-controller,image-automation-controller \
--owner=${GITHUB_USER} \
--repository=${GITHUB_REPO} \
--branch=main \
--personal \
--path=clusters/staging/northeurope \
--token-auth
```

## 2 Wait for the `tenants` Kustomization to reconcile

## 3. Setup tenants

### Tenant's repos

https://github.com/mfamador/gitops-demo-tenant-data

https://github.com/mfamador/gitops-demo-tenant-core

### 3.1 Create `data` tenant

### 3.1.1 Setup RBAC

```bash
flux create tenant data \
--label=istio-injection=enabled \
--with-namespace=data \
--export > ./tenants/base/data/rbac.yaml
```

### 3.1.2 Setup git source and Kustomization

```bash
flux create source git data \
--namespace=data \
--url=https://github.com/mfamador/gitops-demo-tenant-data \
--secret-ref=data \
--branch=main \
--export > ./tenants/base/data/sync.yaml

flux create kustomization data \
--namespace=data \
--source=data \
--service-account=data \
--path="./" \
--prune=true \
--interval=5m \
--export >> ./tenants/base/data/sync.yaml
```

### 3.1.3 Setup `data` secret

`❯ kubectl get secret -n flux-system flux-system -oyaml > data-secret.yaml`

Rename the secret and namespace to `data` and remove the managed and other fields.

`❯ kubectl apply -f data-secret.yaml`


### 3.2 Create `core` tenant

### 3.2.1 Setup RBAC

```bash
flux create tenant core \
--label=istio-injection=enabled \
--with-namespace=core \
--export > ./tenants/base/core/rbac.yaml
```

### 3.2.2 Setup git source and Kustomization

```bash
flux create source git core \
--namespace=core \
--url=https://github.com/mfamador/gitops-demo-tenant-core \
--secret-ref=core \
--branch=main \
--export > ./tenants/base/core/sync.yaml

flux create kustomization core \
--namespace=core \
--source=core \
--service-account=core \
--path="./" \
--prune=true \
--interval=5m \
--export >> ./tenants/base/core/sync.yaml
```

### 3.2.3 Setup `core` secret

`❯ kubectl get secret -n flux-system flux-system -oyaml > core-secret.yaml`

Rename the secret and namespace to `core` and remove the managed and other fields.

`❯ kubectl apply -f core-secret.yaml`
