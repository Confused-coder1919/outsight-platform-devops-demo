# Outsight Platform DevOps Demo

## 60-second overview

This is a compact, interview-ready demo of a multi-tenant SaaS-style Kubernetes platform.
It packages a tiny FastAPI app, deploys it to two tenant namespaces via Helm and Argo CD,
and wires CI/CD (GitHub Actions + GitLab CI) with GitOps-driven image updates. Prometheus,
Grafana, and Loki provide tenant-aware metrics and logs.

## Quickstart (5 min)

```bash
make k3d
make observability
make argocd
make gitops
```

Quick checks:
```bash
kubectl get pods -n tenant-a
kubectl get pods -n tenant-b
```

## CI/CD + GitOps flow (short)

- PRs: lint + tests only.
- Push to `main`: build/push image to GHCR, update tenant image values, open a GitOps PR.
- Argo CD syncs the merged values into tenant namespaces.
- Local note: Argo CD reads tenant values from `charts/demo-api/tenants/`. CI updates
  `gitops/tenants/` for GitOps PRs, so keep them in sync when demoing locally.

## Local Docker (sanity check)

```bash
make docker-build TAG=dev
make docker-run TAG=dev
```

```bash
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:8000/metrics | head -n 5
```

## Local image (no GHCR)

Build the image with the same GHCR name used by the chart so k3d can find it locally
when `imagePullPolicy: IfNotPresent` is set.

```bash
docker build -t ghcr.io/confused-coder1919/outsight-platform-devops-demo/demo-api:dev .
```

## Docs

- `docs/ARCHITECTURE.md`
- `docs/RUNBOOK.md`
- `docs/REPORT.md`
- `docs/INTERVIEW_TALK_TRACK.md`
- `docs/DEMO_SCRIPT.md`
