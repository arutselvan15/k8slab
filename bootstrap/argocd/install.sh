#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES="${SCRIPT_DIR}/values.yaml"

usage() {
  cat <<EOF
Usage: $(basename "$0") [kubectl-context]

Day 1 — installs or upgrades Argo CD with Helm. Safe to re-run.

If context is omitted, uses the current kubectl context.

Example:
  $(basename "$0") kind-dev
EOF
}

KUBE_CONTEXT="${1:-}"
if [[ -z "$KUBE_CONTEXT" ]]; then
  KUBE_CONTEXT="$(kubectl config current-context 2>/dev/null || true)"
fi
if [[ -z "$KUBE_CONTEXT" ]]; then
  echo "No kubectl context set. Pass context or run: kubectl config use-context kind-dev" >&2
  usage
  exit 1
fi

if ! kubectl config get-contexts -o name 2>/dev/null | grep -qx "$KUBE_CONTEXT"; then
  echo "Unknown kubectl context: $KUBE_CONTEXT" >&2
  exit 1
fi

echo "Using kubectl context: $KUBE_CONTEXT"

echo "Adding Argo CD Helm repo ..."
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
helm repo update

echo "Creating namespace argocd ..."
kubectl --context "$KUBE_CONTEXT" create namespace argocd \
  --dry-run=client -o yaml | kubectl --context "$KUBE_CONTEXT" apply -f -

echo "Installing or upgrading Argo CD ..."
helm --kube-context "$KUBE_CONTEXT" upgrade \
  --install argocd argo/argo-cd \
  --namespace argocd \
  --values "$VALUES" \
  --wait

echo "Argo CD ready on context $KUBE_CONTEXT."
