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

Dev ingress hostname and TLS secret name: [`argocd/values/overlays/dev.yaml`](argocd/values/overlays/dev.yaml) (Helm); Secret material from GitOps **`argocd-server-tls`** Certificate.

## Dev: ingress + TLS (two steps)

Argo CD itself is **Day 1 Helm**; platform TLS is **Day 2 GitOps**.

```text
GitOps sync                    Bootstrap (Helm)
───────────                    ────────────────
ingress-nginx          →       (routing ready)
cert-manager           →       CRDs + controller
core-certificates      →       ClusterIssuer + Certificate → Secret argocd-server-tls
                               ↓ Certificate Ready
./bootstrap/bootstrap.sh dev   → server.ingress enabled, secretName argocd-server-tls
```

1. Push and sync [gitops](../gitops/README.md) until **`kubectl get certificate -n argocd argocd-server-tls`** shows **Ready**.
2. Re-run **`./bootstrap/bootstrap.sh dev`** so the dev overlay mounts that Secret on the ingress.

Helm values live in **`argocd/values/base.yaml`** (shared ingress defaults, disabled by default) + **`overlays/<profile>.yaml`**. See [`argocd/values/overlays/README.md`](argocd/values/overlays/README.md).

## Argo CD UI (dev)

After GitOps sync + Certificate Ready + **`./bootstrap/bootstrap.sh dev`** (ingress in [`argocd/values/overlays/dev.yaml`](argocd/values/overlays/dev.yaml)):

**https://argocd.dev:8443** — add `127.0.0.1 argocd.dev` to `/etc/hosts`.

Until then, port-forward:

```bash
kubectl port-forward svc/argocd-server -n argocd 8888:80
```

User **`admin`**. Optional **`ARGOCD_ADMIN_PASSWORD`** in `bootstrap.env` (patched after Helm). Otherwise:

`kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode; echo`

[`../gitops/README.md`](../gitops/README.md) — push Git, apply or refresh `core.application.yaml`, verify **`core-certificates`**.

## What stays in bootstrap (not GitOps)

| Concern | Why |
|---------|-----|
| Argo CD Helm install | GitOps controller must exist before Applications |
| Repo / repo-creds Secrets | Argo needs clone access before first sync |
| Dev ingress **enable** + `secretName` | Chart is Day 1; TLS **material** comes from Day 2 `Certificate` — re-run bootstrap after cert is Ready |
