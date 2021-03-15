# GitOps Workflow with Flux v2 - Multi-Tenancy

[![test](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/test.yaml/badge.svg)](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/test.yaml)
[![e2e](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/e2e.yaml/badge.svg)](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/e2e.yaml)
[![license](https://img.shields.io/github/license/mfamador/gitops-demo-multitenant.svg)](https://github.com/mfamador/gitops-demo-multitenant/blob/main/LICENSE)

_For the original example see [flux2-multi-tenancy](https://github.com/fluxcd/flux2-multi-tenancy)._

---

# Scenario

```bash
k3d cluster create -p 8080:80@loadbalancer --agents 3 --k3s-server-arg "--no-deploy=traefik"

export GIT_ACCESS_TOKEN=<REDACTED>
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

### Tenant's repos

https://github.com/mfamador/gitops-demo-multitenant

https://github.com/mfamador/gitops-demo-tenant-core

https://github.com/mfamador/gitops-demo-tenant-data

## Create `data` tenant

```bash
flux create tenant data --with-namespace=core \
--export > ./tenants/base/data/rbac.yaml

# create the tenant's git source
flux create source git data \
--namespace=data \
--url=https://github.com/mfamador/gitops-demo-tenant-data \
--branch=main

# create the tenant's git source
flux create source git core \
--namespace=core \
--url=https://github.com/mfamador/gitops-demo-tenant-data \
--branch=main

# export the config to tenant folder
flux create source git data \
--url=https://github.com/mfamador/gitops-demo-tenant-data \
--branch=main \
--secret-ref=data \
--export > ./tenants/base/data/sync.yaml

IMPORTANT: 
add serviceAccountName: data
and create secret from flux-system secret

flux create kustomization data \
--source=data \
--path="./staging/northeurope" \
--prune=true \
--interval=5m \
--export >> ./tenants/base/data/sync.yaml


```
