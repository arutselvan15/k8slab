#!/bin/bash

set -euo pipefail

echo "Adding ArgoCD Helm repo..."

helm repo add argo https://argoproj.github.io/argo-helm

helm repo update

echo "Creating namespace..."

kubectl create namespace argocd \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Installing ArgoCD..."

helm upgrade \
  --install argocd argo/argo-cd \
  --namespace argocd \
  --values values.yaml \
  --wait

echo "ArgoCD installed."