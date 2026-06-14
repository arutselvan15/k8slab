# Day 2 — GitOps

Platform workloads are declared in Git and synced by **Argo CD** (installed in Day 1). Shell scripts do not install ingress, cert-manager, or apps after bootstrap.

Full reference for this repo: concepts below, then step-by-step **Deploy dev core**.

---

## Three Argo CD building blocks

| Kind | Example in this repo | Purpose |
|------|----------------------|---------|
| **AppProject** | `core.appproject.yaml` → AppProject **`core`** | **Policy**, not a deployable app. Defines which Git repos, clusters/namespaces, and resource types member Applications may use. Platform apps use `spec.project: core`. |
| **Application (App of Apps)** | `core.application.yaml` → Application **`core-apps`** | **Orchestrator.** One Application whose Git path contains AppProject + other Application manifests. Syncs “what to run” into the `argocd` namespace. Applied **once** from your laptop/CI (seed); not created by GitOps itself. |
| **Application (platform app)** | `ingress-nginx.application.yaml` | **Real delivery.** Helm chart + values → target namespace (e.g. `ingress-nginx`, `cert-manager`). |
| **Application (platform TLS)** | `core-certificates.application.yaml` | **cert-manager CRs** only (`ClusterIssuer`, `Certificate` under `core/certificates/`). Separate app so CRDs exist before sync. |

**Analogy:** AppProject = firewall rules for a team. App-of-Apps = folder that lists which Argo apps exist. Platform Application = installs nginx/cert-manager. **`core-certificates`** = shared folder for all core infra TLS manifests (Argo CD today; more YAML files as you add services).

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
        ├── wave 10   Application "ingress-nginx"
        ├── wave 20   Application "cert-manager" (Helm → CRDs)
        └── wave 25   Application "core-certificates" → core/certificates/ (Issuers + Certificates)
```

**Why a separate Application for TLS?** cert-manager CRDs exist only after the `cert-manager` Helm release syncs. `core-apps` uses `directory.exclude: certificates/*` so it does not apply those manifests in the same pass; **`core-certificates`** syncs all infra TLS under `core/certificates/` afterward (Argo CD today; add more YAML as needed).

**`gitops/apps/`** holds Helm **values** only (no Application CRs). Child apps reference them via multi-source `$values/gitops/apps/...`.

---

## Repository layout

```text
gitops/
├── apps/
│   ├── ingress-nginx/
│   │   └── values.yaml
│   └── cert-manager/
│       └── values.yaml
└── clusters/
    └── dev/
        ├── core.application.yaml   # exclude certificates/* from core-apps recurse
        └── core/
            ├── core.appproject.yaml
            ├── certificates/          # infra TLS (synced by Application core-certificates)
            │   ├── clusterissuer-selfsigned.yaml
            │   └── argocd-server-certificate.yaml   # example: Argo CD ingress
            └── applications/
                ├── ingress-nginx.application.yaml
                ├── cert-manager.application.yaml
                └── core-certificates.application.yaml
```

---

## Prerequisites

1. **Day 1 done** — Argo CD running (`./scripts/kind-up.sh dev` includes Day 1; or `./bootstrap/bootstrap.sh` alone).
2. **Git repo registered** — `argocd/install.sh` applies `repo.*.yaml` and `repo-creds.*.yaml` (placeholders from [`../bootstrap/env/bootstrap.env`](../bootstrap/env/bootstrap.env) via envsubst).
3. **`KUBECONFIG`** set ([`../scripts/kubeconfig-setup.sh`](../scripts/kubeconfig-setup.sh)).
4. **Push to Git** — same URLs as in Application manifests (Argo clones remote, not your laptop tree).

---

## Deploy dev core (step by step)

### 1. Align Git URLs

Match **`repoURL`** in:

- `gitops/clusters/dev/core.application.yaml`
- Each platform Application’s `ref: values` source
- `core.appproject.yaml` → `sourceRepos`

Edit `bootstrap/argocd/repos/repo.k8s-platform.yaml` and `env/defaults.env` (`GIT_REPO_URL`) if needed.

### 2. Push Git

```bash
git add gitops/
git commit -m "Day 2: core platform gitops"
git push
```

### 3. Apply the seed (App of Apps entrypoint)

If you used `./scripts/kind-up.sh dev`, this step is already done **once**. Re-apply when **`gitops/clusters/dev/core.application.yaml`** changes (e.g. `directory.exclude` for `certificates/*`):

```bash
kubectl apply -f gitops/clusters/dev/core.application.yaml
```

This creates or updates **`core-apps`** only. Do **not** `kubectl apply` files under `core/applications/` by hand.

### 4. Verify

```bash
kubectl get appprojects -n argocd
kubectl get applications -n argocd
# expect: core-apps, ingress-nginx, cert-manager, core-certificates (Synced)
kubectl get pods -n ingress-nginx
kubectl get pods -n cert-manager
kubectl get clusterissuer selfsigned
kubectl get certificate -n argocd argocd-server-tls
kubectl get ingress -n argocd
```

Add **`127.0.0.1 argocd.dev`** to `/etc/hosts`.

When **`argocd-server-tls`** is Ready, enable Argo ingress (dev overlay):

```bash
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
./bootstrap/bootstrap.sh dev
```

Open **`https://argocd.dev:8443`** (self-signed; browser warning is expected on Kind).

Kind ingress node ports: **http://localhost:8080** / **https://localhost:8443** (see `infra/kind/dev-cluster.yaml`).

### 5. Migrate old seeds (if any)

```bash
kubectl delete application dev-root -n argocd --ignore-not-found
kubectl delete application core-root -n argocd --ignore-not-found
```

---

## Troubleshooting

### `core-apps` OutOfSync — Certificate / ClusterIssuer CRD not found

**Cause:** TLS manifests were under `core/` and `core-apps` applied them before cert-manager installed CRDs (see sync diagram above).

**Fix:** Ensure `core.application.yaml` excludes `certificates/*` and TLS is synced by **`core-certificates`**, then **push to Git** and refresh:

```bash
kubectl patch application core-apps -n argocd --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
```

### `Resource not found` — Application `cert-manager`

Usually the same failed `core-apps` sync: the `cert-manager` Application CR never got created. After the layout fix and push, `core-apps` should sync wave 20 successfully; then `cert-manager` and `core-certificates` auto-sync.

---

## Add another core component

1. `gitops/apps/<name>/values.yaml`
2. `gitops/clusters/dev/core/applications/<name>.application.yaml` (`spec.project: core`, sync-wave after deps)
3. Update **`core.appproject.yaml`**: `sourceRepos`, `destinations`
4. Commit, push — **`core-apps`** sync adds the Application

Example already in repo: **ingress-nginx** (chart `4.12.1`), **cert-manager** (`v1.17.2`), **core-certificates** (Issuers + Certificates).

### Add a core infra certificate

1. Add a `Certificate` (and optional `Issuer`) YAML under **`gitops/clusters/dev/core/certificates/`** — do not remove `directory.exclude: certificates/*` from the seed.
2. Keep **`secretName`** / DNS names aligned with the consuming app (e.g. Argo CD: [`bootstrap/argocd/values/overlays/dev.yaml`](../bootstrap/argocd/values/overlays/dev.yaml) `server.ingress.secretName`).
3. Commit, push — **`core-certificates`** syncs the new file (no new Application CR unless you split paths later).

---

## What stays outside GitOps

| Phase | Installed by |
|--------|----------------|
| Cluster (Day 0) | Kind / Terraform |
| Argo CD (Day 1) | `bootstrap.sh` → `argocd/install.sh` (Helm + repos) |
| Git repo + GitHub creds | [`bootstrap/argocd/repos/`](../bootstrap/argocd/repos/) + [`bootstrap/env/`](../bootstrap/env/) |
| Seed **`core-apps`** | `kubectl apply -f core.application.yaml` (once per env) |

---

See also: [`../docs/platform-lifecycle.md`](../docs/platform-lifecycle.md), [Day 1 bootstrap](../bootstrap/README.md).
