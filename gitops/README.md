# Day 2 — GitOps

Platform and application workloads are declared here and synced by **Argo CD** (Day 1).

Nothing in Day 2 is installed by shell scripts after bootstrap, except optionally **registering the first Application** (below).

## Layout

```text
gitops/
├── apps/
│   └── ingress-nginx/          # Helm values for Argo CD
└── clusters/
    └── dev/
        └── ingress-nginx.application.yaml
```

## Prerequisites

- Day 1 complete (Argo CD running)
- `KUBECONFIG` pointed at the cluster
- This repository available to Argo CD (push to GitHub/GitLab or use a reachable remote)

## Register the Git repo in Argo CD

Replace the `ref: values` source URL in cluster Applications with your remote:

```bash
# CLI example (UI: Settings → Repositories)
argocd repo add https://github.com/YOUR_ORG/k8s-platform.git
```

For a **local-only** loop without pushing, use a tunnel or temporary remote; Argo CD must clone the repo that holds `gitops/apps/ingress-nginx/values.yaml`.

## Deploy ingress-nginx (dev)

Chart version is pinned on the Application: `gitops/clusters/dev/ingress-nginx.application.yaml` (`targetRevision`).

```bash
# Edit repoURL in gitops/clusters/dev/ingress-nginx.application.yaml if needed
kubectl apply -f gitops/clusters/dev/ingress-nginx.application.yaml
```

Or sync from the Argo CD UI after applying the Application manifest.

Kind maps **http://localhost:8080** and **https://localhost:8443** to node ports **80/443** when ingress-nginx `hostPort` is enabled (see Kind cluster configs under `infra/kind/`).

Verify:

```bash
kubectl get pods -n ingress-nginx
kubectl get ingressclass
```

## Next components (planned)

cert-manager, metrics-server, monitoring, policies — add under `gitops/apps/` and `gitops/clusters/<profile>/`.

See [`../docs/platform-lifecycle.md`](../docs/platform-lifecycle.md).
