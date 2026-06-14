# k8s-platform

**Day 0** — cluster · **Day 1** — Argo CD · **Day 2** — platform from Git  

Local learning uses **Kind**; **Terraform** can replace Day 0 later without changing Day 1 or Day 2.

---

## Quick start

**Once** (make scripts executable):

```bash
chmod +x scripts/*.sh infra/kind/*.sh bootstrap/bootstrap.sh bootstrap/argocd/install.sh
```

**Local secrets (optional):** copy [`bootstrap/env/bootstrap.env.example`](bootstrap/env/bootstrap.env.example) → `bootstrap.env` (e.g. `GITHUB_PAT`, `ARGOCD_ADMIN_PASSWORD`).

**One command** (dev profile):

```bash
./scripts/kind-up.sh dev
```

This runs:

1. **Day 0** — Kind cluster + kubeconfig (`.kube/kind-dev.yaml`)
2. **Day 1** — Argo CD (Helm + repo Secrets)
3. **Day 2 seed** — `kubectl apply` of `gitops/clusters/dev/core.application.yaml` (App of Apps **`core-apps`**)

**After `kind-up`:** push `gitops/` to GitHub (same URL as in manifests). Argo syncs **ingress-nginx**, **cert-manager**, and **core-certificates** (platform TLS under `core/certificates/`). When the Argo CD `Certificate` is Ready, run **`./bootstrap/bootstrap.sh dev`** again so Helm enables ingress with secret **`argocd-server-tls`**. Use **`https://argocd.dev:8443`** with `127.0.0.1 argocd.dev` in `/etc/hosts`. Details: [gitops/README.md](./gitops/README.md), [bootstrap/README.md](./bootstrap/README.md).

If you change **`core.application.yaml`** (e.g. `directory.exclude`), re-apply the seed: `kubectl apply -f gitops/clusters/dev/core.application.yaml`.

Push this repo to GitHub so Argo CD can sync. If Applications stay **OutOfSync**, see troubleshooting in [gitops/README.md](./gitops/README.md).

Other profiles: `./scripts/kind-up.sh stg|prod` (Day 2 runs only when `gitops/clusters/<profile>/core.application.yaml` exists).

**Teardown:**

```bash
./infra/kind/destroy.sh dev
```

---

## Documentation

| Topic | Doc |
|--------|-----|
| Day 0 — Kind / Terraform | [infra/README.md](./infra/README.md) |
| Day 1 — Argo CD, env, repos | [bootstrap/README.md](./bootstrap/README.md) |
| Day 2 — App of Apps, platform apps | [gitops/README.md](./gitops/README.md) |
| Phases and manual steps | [docs/platform-lifecycle.md](./docs/platform-lifecycle.md) |
