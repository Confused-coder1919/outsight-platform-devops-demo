# Repository Context

## Purpose

This repo is an interview-ready, multi-tenant Kubernetes demo that shows a full DevOps loop:
CI/CD builds and publishes a container, GitOps updates tenant values, Argo CD syncs the
cluster, and Prometheus/Grafana/Loki provide observability. It is intentionally small but
realistic and runnable locally on k3d.

## High-level flow

1) Developer pushes code.
2) CI runs lint/tests, builds the image, pushes to GHCR, and opens a PR updating tenant
   image tags in `gitops/tenants/*-values.yaml`.
3) Argo CD watches the repo and syncs the Helm chart with tenant-specific values.
4) Prometheus scrapes each tenant via ServiceMonitor; Grafana dashboards visualize metrics;
   Loki/Promtail provide tenant-labeled logs.

## Key components

- App (FastAPI): `app/main.py`
  - Endpoints: `/`, `/health`, `/metrics`.
  - Uses `TENANT_NAME` env var for tenant-specific output and metric labels.
- Tests: `tests/test_main.py`
- Container: `Dockerfile`

## Kubernetes + Helm

- Helm chart: `charts/demo-api`
  - Templates: Deployment, Service, ServiceMonitor.
  - Values: `tenantName`, `image.repository`, `image.tag`, ServiceMonitor labels.
- Tenants:
  - `gitops/tenants/tenant-a-values.yaml`
  - `gitops/tenants/tenant-b-values.yaml`
  - Each overrides `tenantName` and image tag/repo.

## GitOps (Argo CD)

- Applications:
  - `gitops/argocd/tenant-a-app.yaml`
  - `gitops/argocd/tenant-b-app.yaml`
- Each points to `charts/demo-api` and uses its tenant values file.
- Uses `CreateNamespace=true` to auto-create `tenant-a` and `tenant-b` namespaces.

## CI/CD

- GitHub Actions: `.github/workflows/ci.yml`
  - Lint + tests on PRs/pushes.
  - On push to main: build/push image to GHCR, update image tag in tenant values,
    open a PR for GitOps changes.
  - Image repo is defined as `IMAGE_REPO` (align with tenant values files).
- GitLab CI: `.gitlab-ci.yml`
  - Mirrors lint/test/build/push stages for parity.

## Observability

- Helm values:
  - `observability/helm-values/kube-prometheus-stack-values.yaml`
  - `observability/helm-values/loki-stack-values.yaml`
- Grafana dashboard JSON:
  - `observability/grafana/dashboards/tenant-overview.json`
- Loki queries:
  - `observability/LOKI_QUERIES.md`

## Scripts (idempotent)

- `scripts/bootstrap_k3d.sh`: create local k3d cluster.
- `scripts/install_argocd.sh`: install Argo CD.
- `scripts/install_observability.sh`: install Prometheus/Grafana/Loki.
- `scripts/deploy_gitops.sh`: apply Argo CD Applications.

## Docs

- `docs/ARCHITECTURE.md`: architecture, flow, and tradeoffs.
- `docs/RUNBOOK.md`: exact commands to run locally.
- `docs/REPORT.md`: internship-aligned report.
- `docs/INTERVIEW_TALK_TRACK.md`: pitch and Q&A.
- `docs/DEMO_SCRIPT.md`: live demo steps and troubleshooting.

## Placeholders to update

- GHCR repo path:
  - `gitops/tenants/tenant-a-values.yaml`
  - `gitops/tenants/tenant-b-values.yaml`
  - `.github/workflows/ci.yml` `IMAGE_REPO`
- Argo CD repo URL:
  - `gitops/argocd/tenant-a-app.yaml`
  - `gitops/argocd/tenant-b-app.yaml`

## Quick local run

```bash
make k3d
make observability
make argocd
make gitops
```

Verify:
```bash
kubectl get pods -n tenant-a
kubectl get pods -n tenant-b
```

## Expected tenant behavior

- `tenant-a` returns `{ "tenant": "tenant-a" }` at `/`.
- `tenant-b` returns `{ "tenant": "tenant-b" }` at `/`.
- `/metrics` exposes Prometheus metrics with tenant labels.

## Notes for reviewers

- Namespace isolation is the multi-tenant model for this demo.
- Centralized observability trades simplicity for shared blast radius.
- GitOps PR flow is used to keep changes auditable.
