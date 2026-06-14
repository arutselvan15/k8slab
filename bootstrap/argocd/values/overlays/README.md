# Argo CD value overlays

Helm merges [`../base.yaml`](../base.yaml) with one overlay per profile.

| Overlay | Use |
|---------|-----|
| `dev.yaml` | Kind: **ingress enabled**, hostname **`argocd.dev`**, TLS secret **`argocd-server-tls`** (from GitOps `Certificate`), `server.insecure: true`, `url: https://argocd.dev:8443` |
| `stg.yaml` | Pre-production (`server.insecure: false`; enable ingress when ready) |
| `prod.yaml` | Production replicas + `server.insecure: false` |

## Dev ingress + cert-manager

- **Secret `argocd-server-tls`** is **not** created by Helm. It is issued by cert-manager via [`../../../gitops/clusters/dev/core/certificates/argocd-server-certificate.yaml`](../../../gitops/clusters/dev/core/certificates/argocd-server-certificate.yaml) (synced by Application **`core-certificates`**).
- First **`./bootstrap/bootstrap.sh dev`** installs Argo CD (ingress may be enabled in overlay but Secret appears only after GitOps).
- When **`kubectl get certificate -n argocd argocd-server-tls`** is **Ready**, run **`./bootstrap/bootstrap.sh dev`** again so the ingress picks up the Secret.

Install:

```bash
./bootstrap/argocd/install.sh dev
```

Shared ingress defaults (class `nginx`, backend HTTP, SSL redirect) live in **`base.yaml`**. Dev overlay repeats key annotations where needed for clarity.

For cloud-only tweaks later, add overlays (e.g. `eks-prod.yaml`) or extend these files.
