# k8s-platform

**Day 0** — infra (cluster) · **Day 1** — bootstrap (Argo CD) · **Day 2** — gitops start (platform from Git)

Local learning uses **Kind**; **Terraform** can replace Day 0 later without changing Day 1 or Day 2.

---

## Quick start

**Once** (make scripts executable):

```bash
chmod +x scripts/*.sh infra/kind/*.sh bootstrap/bootstrap.sh bootstrap/argocd/install.sh
```

**Local secrets (optional):** copy [`bootstrap/env/bootstrap.env.example`](bootstrap/env/bootstrap.env.example) → `bootstrap.env` (e.g. `GITHUB_PAT`, `ARGOCD_ADMIN_PASSWORD`).

**Three steps (dev):**

```bash
# Day 0 + Day 1 (Kind + Argo CD)
./scripts/kind-up.sh dev

# Push GitOps manifests (Argo clones GitHub, not your laptop)
git push origin main

# Day 2 — App of Apps seed (core-apps)
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
./scripts/gitops-start.sh dev
```

When **`argocd-server-tls`** is Ready, run **`./bootstrap/bootstrap.sh dev`** again for ingress → **https://argocd.dev:8443** (`127.0.0.1 argocd.dev` in `/etc/hosts`).

Details: [infra/README.md](./infra/README.md) · [bootstrap/README.md](./bootstrap/README.md) · [gitops/README.md](./gitops/README.md)

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
| Day 2 — GitOps (Apps-of-Apps) | [gitops/README.md](./gitops/README.md) |
| Phases and manual steps | [docs/platform-lifecycle.md](./docs/platform-lifecycle.md) |
| Learning path (concepts + order) | [knowledge/README.md](./knowledge/README.md) |
