# Runbook

This runbook provisions a local k3d cluster, installs Argo CD and observability,
and deploys both tenants via GitOps.

## Prerequisites

- Docker
- kubectl
- helm
- k3d

## Clone and enter repo

```bash
git clone https://github.com/CHANGEME/outsight-platform-devops-demo.git
cd outsight-platform-devops-demo
```

## Create local cluster

```bash
make k3d
```

## Install observability

```bash
make observability
```

## Install Argo CD

```bash
make argocd
```

## Deploy GitOps applications

```bash
make gitops
```

## Verify workloads

```bash
kubectl get ns
kubectl get pods -n tenant-a
kubectl get pods -n tenant-b
```

## Access the app

```bash
kubectl -n tenant-a port-forward svc/demo-api 8081:80
curl http://localhost:8081/

kubectl -n tenant-b port-forward svc/demo-api 8082:80
curl http://localhost:8082/
```

## Access Argo CD UI

```bash
kubectl -n argocd port-forward svc/argocd-server 8083:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Open https://localhost:8083 and login as `admin` with the decoded password.

## Access Grafana

```bash
kubectl -n observability port-forward svc/kube-prometheus-stack-grafana 3000:80
```

Open http://localhost:3000 and login with `admin` / `admin`.
Import the dashboard from `observability/grafana/dashboards/tenant-overview.json`.

## View logs in Loki

In Grafana Explore, select the Loki datasource and try the queries in:
`observability/LOKI_QUERIES.md`.

## Optional: local image build

```bash
make docker-build TAG=dev
```

## Notes

- Update the Git repository URL in `gitops/argocd/tenant-a-app.yaml` and
  `gitops/argocd/tenant-b-app.yaml` to point at your fork.
- Update `image.repository` in `gitops/tenants/*.yaml` to match your GHCR path.
- Keep `.github/workflows/ci.yml` `IMAGE_REPO` aligned with the same GHCR path.
