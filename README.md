# GitOps Workflow with Flux v2 - Multi-Tenancy

[![test](https://github.com/mfamador/gitops-demo-multitenant/workflows/test/badge.svg)](https://github.com/mfamador/gitops-demo-multitenant/actions)
[![e2e](https://github.com/mfamador/gitops-demo-multitenant/workflows/e2e/badge.svg)](https://github.com/mfamador/gitops-demo-multitenant/actions)
[![license](https://img.shields.io/github/license/mfamador/gitops-demo-multitenant.svg)](https://github.com/mfamador/gitops-demo-multitenant/blob/main/LICENSE)

_For the original example see [flux2-multi-tenancy](https://github.com/fluxcd/flux2-multi-tenancy).

---

# Scenario



flux create tenant core-team --with-namespace=core \
--export > ./tenants/base/core-team/rbac.yaml

flux create source git data-team \
--namespace=data \
--url=https://github.com/mfamador/gitops-demo-tenant-data \
--branch=main \
--export > ./tenants/base/data-team/sync.yaml
