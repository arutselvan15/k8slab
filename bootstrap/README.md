# Day 1 — Bootstrap (GitOps controller)

Install **Argo CD** with Helm, then apply Argo CD **repo-creds** and **repository** Secrets from `argocd/repos/`.

Platform workloads are **Day 2** ([`../gitops/`](../gitops/)).

## How it runs

```text
bootstrap/bootstrap.sh [overlay]
        │
        └── argocd/install.sh [overlay]
                  ├── load bootstrap/env/ (defaults.env + bootstrap.env)
                  ├── Helm: argo-cd chart (pin in defaults.env)
                  ├── apply repo-creds.*.yaml  (envsubst if ${VAR} present)
                  └── apply repo.*.yaml
```

- **`bootstrap.sh`** — thin wrapper; does **not** load env (overlay optional, forwarded to `install.sh`).
- **`argocd/install.sh`** — Day 1 implementation; **only** place that sources `env/load.sh`.

Prerequisites on `PATH` for local one-shot: [`../scripts/require-tools.sh`](../scripts/require-tools.sh) (`kubectl`, `helm`, `envsubst`) — called from [`../scripts/kind-up.sh`](../scripts/kind-up.sh). Run Day 1 directly only after those tools are installed.

## Configuration

```text
bootstrap/env/
├── defaults.env           # committed — ARGO_CD_CHART_VERSION, ARGOCD_OVERLAY, GIT_REPO_URL
├── bootstrap.env.example  # template
├── bootstrap.env          # gitignored — secrets and overrides
└── load.sh                # sourced by argocd/install.sh only
```

```bash
cp bootstrap/env/bootstrap.env.example bootstrap/env/bootstrap.env
# optional: GITHUB_PAT, GITHUB_SSH_PRIVATE_KEY_B64 for private GitHub
```

Details: [`env/README.md`](env/README.md). Repo manifests: [`argocd/repos/README.md`](argocd/repos/README.md).

Kubeconfig (cluster targeting) is separate:

```bash
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
```

## Run Day 1

```bash
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
./bootstrap/bootstrap.sh dev          # or omit overlay → ARGOCD_OVERLAY / dev
# equivalent: ./bootstrap/argocd/install.sh dev
```

Keep `GIT_REPO_URL` in `defaults.env` and `repo.k8s-platform.yaml` aligned with `gitops/clusters/…` Application `repoURL` values.

## Argo CD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8888:80
```

User **`admin`**. Optional **`ARGOCD_ADMIN_PASSWORD`** in `bootstrap.env` (patched after Helm). Otherwise:

`kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode; echo`

## Next

[`../gitops/README.md`](../gitops/README.md) — push Git, apply `core.application.yaml`.
