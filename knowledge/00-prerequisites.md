# Step 0 — Prerequisites

Do this once before Day 0. Same ideas apply on a cloud cluster later (Terraform replaces Kind only).

## What you are building

A **local platform** on macOS using:

- **Day 0** — a Kubernetes cluster exists (`infra/kind/`)
- **Day 1** — Argo CD can read your Git repo (`bootstrap/`)
- **Day 2** — everything else is declared in Git (`gitops/`)

See the phase diagram in [`docs/platform-lifecycle.md`](../docs/platform-lifecycle.md).

## Environment profiles

Use **`dev`**, **`stg`**, **`prod`** consistently:

| Profile | Kind cluster name | Kubeconfig | Host HTTP / HTTPS (Kind maps to node 80/443) |
|---------|-------------------|------------|-----------------------------------------------|
| dev | `dev` | `.kube/kind-dev.yaml` | 8080 / 8443 |
| stg | `stg` | `.kube/kind-stg.yaml` | 9080 / 9443 |
| prod | `prod` | `.kube/kind-prod.yaml` | 80 / 443 |

The Kind cluster name must be **`dev`**, not `kind-dev`, so the kubeconfig context stays readable.

## Tools

```bash
brew install kind kubectl helm gettext   # envsubst from gettext
brew link --force gettext                 # if envsubst missing
```

Or run [`scripts/require-tools.sh`](../scripts/require-tools.sh) — used by [`scripts/kind-up.sh`](../scripts/kind-up.sh).

Optional for custom admin password: `htpasswd` (e.g. Apache `httpd` tools).

## Secrets (optional, Day 1)

```bash
cp bootstrap/env/bootstrap.env.example bootstrap/env/bootstrap.env
```

Edit `bootstrap.env` (gitignored) for `GITHUB_PAT`, SSH key, or `ARGOCD_ADMIN_PASSWORD`. Committed defaults live in [`bootstrap/env/defaults.env`](../bootstrap/env/defaults.env) (`ARGO_CD_CHART_VERSION`, `GIT_REPO_URL`).

## Kubeconfig habit

Always point your shell at the right cluster before bootstrap or kubectl:

```bash
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
```

**Next:** [Step 1 — Day 0 cluster](./01-day0-cluster.md)
