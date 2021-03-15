# GitOps Workflow with Flux v2 - Multi-Tenancy

[![test](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/test.yaml/badge.svg)](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/test.yaml)
[![e2e](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/e2e.yaml/badge.svg)](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/e2e.yaml)
[![license](https://img.shields.io/github/license/mfamador/gitops-demo-multitenant.svg)](https://github.com/mfamador/gitops-demo-multitenant/blob/main/LICENSE)

_For the original example see [flux2-multi-tenancy](https://github.com/fluxcd/flux2-multi-tenancy)._

---
# Bootstrap 

## 1. Bootstrap gitops repo
```bash
k3d cluster create -p 8080:80@loadbalancer --agents 4 --k3s-server-arg "--no-deploy=traefik"

export GIT_ACCESS_TOKEN=<REDACTED>
export GITHUB_USER=<YOUR_GITHUB_USER>
export GITHUB_REPO=gitops-demo-multitenant

flux bootstrap github \
--components-extra=image-reflector-controller,image-automation-controller \
--owner=${GITHUB_USER} \
--repository=${GITHUB_REPO} \
--branch=main \
--personal \
--path=clusters/staging/northeurope
#--token-auth
```


### Tenant's repos

https://github.com/mfamador/gitops-demo-multitenant

https://github.com/mfamador/gitops-demo-tenant-core

https://github.com/mfamador/gitops-demo-tenant-data

## 2. Create `data` tenant

### 2.1. Create source
```bash
flux create tenant data \
--label=istio-injection=enabled \
--with-namespace=data \
--export > ./tenants/base/data/rbac.yaml

# create the tenant's git source
flux create source git data \
--namespace=data \
--url=ssh://git@github.com/mfamador/gitops-demo-tenant-data.git \
--branch=main
```

### 2.2. Retrieve ssh deploy key and add it to tenant's repo

### 2.3. Generate tenant git source:
```bash
flux create source git data \
--namespace=data \
--url=ssh://git@github.com/mfamador/gitops-demo-tenant-data.git \
--branch=main \
--export > ./tenants/base/data/sync.yaml
```

### 2.4. Append `Kustomization`
```bash
flux create kustomization data \
 --namespace=data \
 --source=data \
 --service-account=data \
 --path="./" \
 --prune=true \
 --interval=5m \
--export >> ./tenants/base/data/sync.yaml
```

