# Demo Script

## Pre-demo checklist

- `gitops/argocd/tenant-a-app.yaml` and `gitops/argocd/tenant-b-app.yaml` point to your fork.
- `gitops/tenants/tenant-a-values.yaml` and `gitops/tenants/tenant-b-values.yaml` use your GHCR image repo.
- Docker, kubectl, helm, and k3d are installed.
- Optional: run `docker login ghcr.io` if you want to pull a private image.

## Demo commands (exact)

### 1) Bootstrap cluster

```bash
make k3d
```

Expected:
- `k3d cluster 'outsight-demo' already exists.` or `Creating k3d cluster 'outsight-demo'...`

### 2) Install observability (Prometheus/Grafana/Loki)

```bash
make observability
```

Expected:
- `Observability stack installed.`

### 3) Install Argo CD

```bash
make argocd
```

Expected:
- `Argo CD installed.`

### 4) Deploy GitOps applications

```bash
make gitops
```

Expected:
- `Applications applied.`

### 5) Verify namespaces and pods

```bash
kubectl get ns
kubectl get pods -n tenant-a
kubectl get pods -n tenant-b
```

Expected:
- `tenant-a` and `tenant-b` namespaces exist.
- One `demo-api` pod per namespace in Running state.

## Show tenant-a vs tenant-b behavior

```bash
kubectl -n tenant-a port-forward svc/demo-api 8081:8000
```

New terminal:
```bash
curl http://localhost:8081/
```

Expected:
```json
{"message":"hello from demo-api","tenant":"tenant-a"}
```

```bash
kubectl -n tenant-b port-forward svc/demo-api 8082:8000
```

New terminal:
```bash
curl http://localhost:8082/
```

Expected:
```json
{"message":"hello from demo-api","tenant":"tenant-b"}
```

## Show Argo CD sync via a Git change

Note: This assumes Argo CD points to your GitHub fork and can pull it.

```bash
git checkout -b demo/tenant-a-change
sed -i '' 's/tenant-a/tenant-a-demo/' gitops/tenants/tenant-a-values.yaml

git add gitops/tenants/tenant-a-values.yaml
git commit -m "chore: update tenant-a label"
git push -u origin demo/tenant-a-change
```

Open a PR and merge it (or push directly to main if you are demoing solo). In Argo CD UI:
- Application `demo-api-tenant-a` goes OutOfSync.
- Then it auto-syncs back to Synced.

Verify behavior:
```bash
kubectl -n tenant-a port-forward svc/demo-api 8081:8000
curl http://localhost:8081/
```

Expected:
```json
{"message":"hello from demo-api","tenant":"tenant-a-demo"}
```

Revert after the demo if needed:
```bash
git checkout main
git branch -D demo/tenant-a-change
```

## Show Prometheus scrape + Grafana dashboard + Loki logs

### Prometheus targets

```bash
kubectl -n observability port-forward svc/kube-prometheus-stack-prometheus 9090:9090
```

Open http://localhost:9090/targets and confirm `demo-api` targets are UP in both namespaces.

### Grafana dashboard

```bash
kubectl -n observability port-forward svc/kube-prometheus-stack-grafana 3000:80
```

Open http://localhost:3000 (admin/admin) and import:
- `observability/grafana/dashboards/tenant-overview.json`

Generate traffic:
```bash
for i in {1..5}; do curl -s http://localhost:8081/ >/dev/null; done
for i in {1..5}; do curl -s http://localhost:8082/ >/dev/null; done
```

Expected:
- Request rate and latency panels show activity for both namespaces.

### Loki logs per tenant

In Grafana Explore, select Loki and run:
- `{tenant="tenant-a"} |= "tenant-a"`
- `{tenant="tenant-b"} |= "tenant-b"`

Expected:
- Log lines like `request path=/ status=200 tenant=tenant-a`.

## Troubleshooting (top 10)

1) Pods stuck in ImagePullBackOff
- Check `image.repository` and GHCR permissions. Run `docker login ghcr.io` if private.

2) Argo CD apps show SyncError
- Ensure `repoURL` points to a reachable repo and `path: charts/demo-api` exists.

3) ServiceMonitor not scraping
- Confirm ServiceMonitor label matches Prometheus selector (`release: kube-prometheus-stack`).

4) Grafana login fails
- Default is `admin/admin` per `observability/helm-values/kube-prometheus-stack-values.yaml`.

5) Loki shows no logs
- Ensure promtail is running and pods have emitted logs. Trigger with `curl` calls.

6) k3d cluster creation fails
- Check Docker is running and port 8000 is free.

7) Argo CD UI not reachable
- Verify port-forward is active: `kubectl -n argocd port-forward svc/argocd-server 8083:443`.

8) `kubectl` context wrong
- Run `kubectl config get-contexts` and select the k3d context.

9) Grafana dashboard panels empty
- Verify Prometheus targets are UP and use the `namespace` filter.

10) Changes not reflected after Git push
- Argo CD may be polling; click Refresh in UI or wait a minute for sync.
