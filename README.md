# k8s-platform

**Day 0** — cluster · **Day 1** — Argo CD · **Day 2** — platform from Git  

Local learning uses **Kind**; **Terraform** can replace Day 0 later without changing Day 1 or Day 2.

---

## Quick start

**Once** (make scripts executable):

```bash
chmod +x scripts/*.sh infra/kind/*.sh bootstrap/bootstrap.sh bootstrap/argocd/install.sh
```

**Private GitHub:** copy and edit [`bootstrap/env/bootstrap.env.example`](bootstrap/env/bootstrap.env.example) → `bootstrap.env` (see [bootstrap/README.md](./bootstrap/README.md)).

**One command** (dev profile):

```bash
./scripts/kind-up.sh dev
```

This runs:

1. **Day 0** — Kind cluster + kubeconfig (`.kube/kind-dev.yaml`)
2. **Day 1** — Argo CD (Helm + repo Secrets)
3. **Day 2** — `kubectl apply` of `gitops/clusters/dev/core.application.yaml` (App of Apps **`core-apps`**)

Push this repo to GitHub (same URL as in gitops manifests) so Argo CD can sync. If Applications stay **OutOfSync**, check repo creds and remote Git — [gitops/README.md](./gitops/README.md).

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
