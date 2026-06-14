# Argo CD value overlays

Helm merges `../base.yaml` with one overlay per install:

| Overlay | Use |
|---------|-----|
| `dev.yaml` | Local Kind; insecure server |
| `stg.yaml` | Pre-production |
| `prod.yaml` | Production (TLS expected; not insecure) |

Install:

```bash
./bootstrap/argocd/install.sh dev
```

For cloud-only tweaks later, add overlays (e.g. `eks-prod.yaml`) or extend these files.
