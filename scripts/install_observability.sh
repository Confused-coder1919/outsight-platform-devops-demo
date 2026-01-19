#!/usr/bin/env bash
set -euo pipefail

PROM_STACK_VERSION="${PROM_STACK_VERSION:-61.3.1}"
LOKI_STACK_VERSION="${LOKI_STACK_VERSION:-2.9.10}"

echo "Adding Helm repos..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "Installing kube-prometheus-stack ${PROM_STACK_VERSION}..."
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --version "${PROM_STACK_VERSION}" \
  --namespace observability \
  --create-namespace \
  -f observability/helm-values/kube-prometheus-stack-values.yaml

echo "Installing Loki stack ${LOKI_STACK_VERSION}..."
helm upgrade --install loki grafana/loki-stack \
  --version "${LOKI_STACK_VERSION}" \
  --namespace observability \
  --create-namespace \
  -f observability/helm-values/loki-stack-values.yaml

echo "Observability stack installed."
