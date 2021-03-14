# GitOps Workflow with Flux v2 - Multi-Tenancy

[![test](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/test.yaml/badge.svg)](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/test.yaml)
[![e2e](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/e2e.yaml/badge.svg)](https://github.com/mfamador/gitops-demo-multitenant/actions/workflows/e2e.yaml)
[![license](https://img.shields.io/github/license/mfamador/gitops-demo-multitenant.svg)](https://github.com/mfamador/gitops-demo-multitenant/blob/main/LICENSE)

_For the original example see [flux2-multi-tenancy](https://github.com/fluxcd/flux2-multi-tenancy)._

---

# Scenario

https://github.com/mfamador/gitops-demo-multitenant

https://github.com/mfamador/gitops-demo-tenant-core

https://github.com/mfamador/gitops-demo-tenant-data

flux create tenant data --with-namespace=core \
--export > ./tenants/base/data/rbac.yaml

flux create source git data \
--namespace=data \
--url=https://github.com/mfamador/gitops-demo-tenant-data \
--branch=main \
--secret-ref=data \
--export > ./tenants/base/data/sync.yaml

flux create kustomization data \
--namespace=data \
--source=data \
--path="./staging/northeurope" \
--prune=true \
--interval=10m \
--export >> ./tenants/base/data/sync.yaml


