# Day 2 — GitOps

Platform workloads are declared in Git and synced by **Argo CD** (installed in Day 1). Shell scripts do not install ingress, cert-manager, or apps after bootstrap.

Full reference for this repo: concepts below, then step-by-step **Deploy dev core**.

---

## Three Argo CD building blocks

| Kind | Example in this repo | Purpose |
|------|----------------------|---------|
| **AppProject** | `core.appproject.yaml` → AppProject **`core`** | **Policy**, not a deployable app. Defines which Git repos, clusters/namespaces, and resource types member Applications may use. Platform apps use `spec.project: core`. |
| **Application (App of Apps)** | `core.application.yaml` → Application **`core-apps`** | **Orchestrator.** One Application whose Git path contains AppProject + other Application manifests. Syncs “what to run” into the `argocd` namespace. Applied **once** from your laptop/CI (seed); not created by GitOps itself. |
| **Application (platform app)** | `ingress-nginx.application.yaml` | **Real delivery.** Points at a Helm chart (and values in this repo) and installs workloads into a target namespace (e.g. `ingress-nginx`). Created automatically when **`core-apps`** syncs. |

**Analogy:** AppProject = firewall rules for a team. App-of-Apps = folder that lists which Argo apps exist. Platform Application = one of those apps actually installing nginx/cert-manager.

---

## How sync flows (dev)

```text
You (once)                Argo CD                         Cluster
─────────                 ───────                         ───────
kubectl apply
  core.application.yaml
        │
        ▼
                    Application "core-apps"
                    (project: default)
                    source: gitops/clusters/dev/core/
        │
        ├── wave -1   AppProject "core"
        │
        └── wave 10   Application "ingress-nginx" (project: core)
                              │
                              └── Helm → ingress-nginx namespace
```

**`gitops/apps/`** holds Helm **values** only (no Application CRs). Child apps reference them via multi-source `$values/gitops/apps/...`.

---

## Repository layout

```text
gitops/
├── apps/
│   └── ingress-nginx/
│       └── values.yaml              # Helm values (Git)
└── clusters/
    └── dev/
        ├── core.application.yaml    # SEED — apply once → creates core-apps
        └── core/                    # SYNCED by core-apps (directory recurse)
            ├── core.appproject.yaml
            └── applications/
                └── ingress-nginx.application.yaml
```

Later: **`cert-manager.application.yaml`** under `core/applications/`, values under `gitops/apps/cert-manager/`. Other domains (Kubeflow, product apps) can get their own AppProject + seed Application under `clusters/dev/`.

---

## Prerequisites

1. **Day 1 done** — Argo CD running; Git repo URL registered in bootstrap ([`../bootstrap/argocd/gitops-repo.env`](../bootstrap/argocd/gitops-repo.env)).
2. **`KUBECONFIG`** set ([`../scripts/kubeconfig-setup.sh`](../scripts/kubeconfig-setup.sh)).
3. **Git remote** — push this repo to the same URL used in manifests (Argo clones GitHub, not your Mac disk).

Private repo at bootstrap:

```bash
export GITOPS_REPO_PASSWORD='ghp_...'
./bootstrap/bootstrap.sh dev
```

---

## Deploy dev core (step by step)

### 1. Align Git URLs

Set [`../bootstrap/argocd/gitops-repo.env`](../bootstrap/argocd/gitops-repo.env) and match **`repoURL`** in:

- `gitops/clusters/dev/core.application.yaml`
- Each platform Application’s `ref: values` source
- `core.appproject.yaml` → `sourceRepos`

Re-run bootstrap if you change the URL there.

### 2. Push Git

```bash
git add gitops/
git commit -m "Day 2: core platform gitops"
git push
```

### 3. Apply the seed (App of Apps entrypoint)

```bash
kubectl apply -f gitops/clusters/dev/core.application.yaml
```

This creates **`core-apps`** only. Do **not** `kubectl apply` files under `core/applications/` by hand.

### 4. Verify

```bash
kubectl get appprojects -n argocd
kubectl get applications -n argocd
# expect: core-apps (Synced), ingress-nginx (Synced)
kubectl get pods -n ingress-nginx
kubectl get ingressclass
```

Argo CD UI: Applications **`core-apps`** → **`ingress-nginx`**.

Kind dev: **http://localhost:8080** / **https://localhost:8443** (see `infra/kind/*-cluster.yaml`, `apps/ingress-nginx/values.yaml`).

### 5. Migrate old seeds (if any)

```bash
kubectl delete application dev-root -n argocd --ignore-not-found
kubectl delete application core-root -n argocd --ignore-not-found
```

---

## Add another core component (e.g. cert-manager)

1. `gitops/apps/cert-manager/values.yaml`
2. `gitops/clusters/dev/core/applications/cert-manager.application.yaml`  
   - `spec.project: core`  
   - `argocd.argoproj.io/sync-wave` after dependencies (e.g. `"20"`)
3. Update **`core.appproject.yaml`**: `sourceRepos`, `destinations` (e.g. `cert-manager` namespace)
4. Commit, push — **`core-apps`** sync adds the new Application; no seed re-apply

Chart version: set Helm **`targetRevision`** on each platform Application (ingress-nginx: `4.12.1`).

---

## What stays outside GitOps

| Phase | Installed by |
|--------|----------------|
| Cluster (Day 0) | Kind / Terraform |
| Argo CD (Day 1) | `bootstrap/bootstrap.sh` |
| Git repo registration | bootstrap `install.sh` |
| Seed **`core-apps`** | `kubectl apply -f core.application.yaml` (once per env) |

---

See also: [`../docs/platform-lifecycle.md`](../docs/platform-lifecycle.md), [Day 1 bootstrap](../bootstrap/README.md).
