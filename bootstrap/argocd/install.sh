#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES="${SCRIPT_DIR}/values.yaml"

usage() {
  cat <<EOF
Usage: $(basename "$0")

Day 1 — installs or upgrades Argo CD with Helm. Safe to re-run.

Uses the current kubectl context.

Example:
  $(basename "$0")
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ -n "${1:-}" ]]; then
  echo "Unexpected argument: $1" >&2
  usage
  exit 1
fi

echo "Adding Argo CD Helm repo ..."
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
helm repo update

echo "Creating namespace argocd ..."
kubectl create namespace argocd \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Installing or upgrading Argo CD ..."
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --values "$VALUES" \
  --wait

echo "Argo CD ready."
