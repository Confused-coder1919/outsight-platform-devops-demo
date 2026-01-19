# Architecture

## ASCII diagram

Developer
  |
  v
GitHub Actions / GitLab CI
  |        \
  |         \__ Docker image -> GHCR
  |
  v
GitOps repo (Helm values)
  |
  v
Argo CD
  |
  v
Kubernetes (k3d)
  |-- namespace: tenant-a -> demo-api
  |-- namespace: tenant-b -> demo-api
  |
  +--> Observability
       |-- Prometheus (scrapes ServiceMonitor per namespace)
       |-- Grafana (dashboards)
       +-- Loki + Promtail (logs per namespace)

## CI -> Image -> GitOps -> Deploy flow

- Developer pushes code to GitHub/GitLab.
- CI runs lint/tests, builds a container, and pushes to GHCR (image repo is lowercased for GHCR compatibility).
- On pushes to `main`, GitHub Actions opens a PR updating `gitops/tenants/*-values.yaml` with the new tag.
- Argo CD watches the repo and syncs the updated Helm values into each tenant namespace.

## Multi-tenant model (namespace isolation)

- Each tenant gets a dedicated namespace (`tenant-a`, `tenant-b`).
- The same Helm chart is deployed twice with different `tenantName` values.
- This keeps workloads separated and provides tenant-scoped metrics/logs via namespace labels.

## Observability model

- Centralized stack in `observability` namespace (Prometheus, Grafana, Loki).
- Each tenant deploys its own ServiceMonitor so metrics are scraped per namespace.
- Promtail carries tenant/app/environment labels into logs for targeted Loki queries.
- Optional cloud-native integration: in production, the same metrics/logs could be
  forwarded to CloudWatch or a managed SaaS; here it is documented only.

## Hardening choices

- NetworkPolicy limits ingress to in-namespace traffic plus Prometheus scraping, and
  restricts egress to DNS (and optional observability endpoints).
- Per-tenant read-only RBAC (tenant viewer) provides safe, scoped visibility.
- Probes and resource requests/limits enforce basic reliability guardrails.
- PodDisruptionBudget keeps at least one pod available during voluntary disruptions.
- Tenant/app/environment labels standardize filtering across metrics and logs.

## Why these choices matter in multi-tenant SaaS

- Isolation controls reduce noisy neighbor risk and accidental cross-tenant access.
- RBAC and labeling provide safe, predictable visibility without over-privileging.
- Reliability guardrails prevent cascading failures from impacting all tenants.

## Tradeoffs and choices

- Namespace isolation is practical for demos but not a hard security boundary.
- Centralized observability reduces ops overhead but increases shared blast radius.
- GitOps PRs provide auditability at the cost of extra CI workflow steps.
