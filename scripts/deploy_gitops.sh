#!/usr/bin/env bash
set -euo pipefail

echo "Applying Argo CD Applications..."
kubectl apply -f gitops/argocd

echo "Applications applied."
