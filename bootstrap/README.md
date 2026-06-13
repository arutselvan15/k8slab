# Day 1 — Bootstrap (GitOps controller)

Install the minimum software needed to manage the cluster from Git: **Argo CD**.

Platform components (ingress, certificates, monitoring, policies) belong in **Day 2** ([`../gitops/`](../gitops/)), not here.

## Layout

```text
bootstrap/
├── bootstrap.sh       # Day 1 entry ([overlay] → dev|stg|prod)
└── argocd/
    ├── install.sh     # Helm install (pinned chart)
    ├── versions.env   # ARGO_CD_CHART_VERSION
    └── values/
        ├── base.yaml
        └── overlays/
            ├── dev.yaml
            ├── stg.yaml
            └── prod.yaml
```

## Prerequisites

- Day 0 complete; kubeconfig file exists
- `KUBECONFIG` set in your shell via [`../scripts/kubeconfig-setup.sh`](../scripts/kubeconfig-setup.sh)
- `helm`, `kubectl`

```bash
brew install kubectl helm
```

## Run Day 1

From the repo root (example: Kind dev):

```bash
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
./bootstrap/bootstrap.sh dev
```

Overlays match profiles (`dev`, `stg`, `prod`). Chart version is pinned in `argocd/versions.env`.

`prod` overlay sets `server.insecure: false` — use TLS/ingress (Day 2) or `dev` overlay on Kind until then.

Or from `bootstrap/` after sourcing with a path relative to repo root:

```bash
cd bootstrap
chmod +x bootstrap.sh argocd/install.sh
source ../scripts/kubeconfig-setup.sh ../.kube/kind-dev.yaml
./bootstrap.sh dev
```

The **overlay** (`dev`, `stg`, `prod`) selects Helm values only. The target cluster comes from `KUBECONFIG`. Default overlay is `dev` if omitted (`ARGOCD_OVERLAY` env also supported).

Re-running upgrades Argo CD via `helm upgrade --install`.

## Argo CD access

Use the same shell where you sourced `kubeconfig-setup.sh`, or source the kubeconfig path again:

```bash
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
```

Admin password:

```bash
kubectl get secret argocd-initial-admin-secret \
  -n argocd -o jsonpath='{.data.password}' | base64 --decode; echo
```

UI (use a port that does not clash with ingress — e.g. **8888** on dev):

```bash
kubectl port-forward svc/argocd-server -n argocd 8888:80
```

Open http://localhost:8888 — user `admin`.

## Cloud clusters

When Terraform replaces Kind, Day 0 produces a kubeconfig file. Same Day 1 flow:

```bash
source scripts/kubeconfig-setup.sh /path/from/terraform/kubeconfig.yaml
./bootstrap/bootstrap.sh prod
```

Helm only (same cluster as current `KUBECONFIG`):

```bash
./bootstrap/argocd/install.sh dev
```

## Next

Populate [`../gitops/`](../gitops/) (Day 2) and register a root Application from Git.
