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

## Docs

- `docs/ARCHITECTURE.md`
- `docs/RUNBOOK.md`
- `docs/REPORT.md`
- `docs/INTERVIEW_TALK_TRACK.md`
- `docs/DEMO_SCRIPT.md`
