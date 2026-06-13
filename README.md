
# k8s-platform

Reference layout for **Day 0 / Day 1 / Day 2** Kubernetes platform bootstrap: infrastructure, GitOps controller, then Git-managed workloads.

Built for learning on **Kind** (macOS); structured so **Terraform** can replace Kind in Day 0 without changing Day 1 or Day 2.

---

## Repository layout

```text
.
├── infra/              # Day 0 — cluster provisioning (Kind or Terraform)
├── bootstrap/          # Day 1 — Argo CD (bootstrap.sh → argocd/install.sh)
│   ├── env/            # defaults.env + gitignored bootstrap.env
│   └── argocd/         # Helm, values/, repos/
├── gitops/             # Day 2 — App of Apps + platform (ingress-nginx, …)
├── scripts/
│   ├── kind-up.sh           # Day 0 + kubeconfig + Day 1 (local one-shot)
│   ├── kubeconfig-setup.sh  # export KUBECONFIG from a file path
│   └── require-tools.sh     # verify commands on PATH (standalone CLI)
├── .kube/              # kubeconfig files (gitignored; created by Day 0)
└── docs/
```

Details: [docs/platform-lifecycle.md](./docs/platform-lifecycle.md)

---

## How the pieces connect

Profile names (**dev**, **stg**, **prod**) select the Kind cluster / kubeconfig file (Day 0) and the Argo CD Helm **overlay** (Day 1).

After the cluster exists:

```text
1. source scripts/kubeconfig-setup.sh <path-to-kubeconfig>
2. ./bootstrap/bootstrap.sh [overlay]   → argocd/install.sh
```

| Script | Role |
|--------|------|
| [`scripts/kind-up.sh`](./scripts/kind-up.sh) | `require-tools.sh` → Kind setup → kubeconfig → `bootstrap.sh` |
| [`scripts/require-tools.sh`](./scripts/require-tools.sh) | `./scripts/require-tools.sh kubectl helm envsubst` (used by `kind-up.sh`) |
| [`scripts/kubeconfig-setup.sh`](./scripts/kubeconfig-setup.sh) | **Must be sourced.** Sets `KUBECONFIG`; runs `kubectl get nodes` |
| [`bootstrap/bootstrap.sh`](./bootstrap/bootstrap.sh) | Delegates to `argocd/install.sh` |
| [`bootstrap/argocd/install.sh`](./bootstrap/argocd/install.sh) | Loads `bootstrap/env/`, Helm install, applies `repos/` |

Configuration: [`bootstrap/env/defaults.env`](./bootstrap/env/defaults.env) (committed) and [`bootstrap/env/bootstrap.env`](./bootstrap/env/bootstrap.env) (gitignored; copy from `bootstrap.env.example`). Env is loaded in **`install.sh` only**.

Future **`scripts/terraform-up.sh`**: Terraform apply → kubeconfig path → same steps 1–2.

---

## Quick start (Kind, local)

From the repo root:

```bash
chmod +x scripts/kind-up.sh scripts/kubeconfig-setup.sh scripts/require-tools.sh \
  infra/kind/*.sh bootstrap/bootstrap.sh bootstrap/argocd/install.sh

./scripts/kind-up.sh dev
```

Or step by step:

```bash
./scripts/require-tools.sh kubectl helm envsubst
./infra/kind/setup.sh dev
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
./bootstrap/bootstrap.sh dev
```

| Profile | Kind cluster name | Kubeconfig file (repo) | Ingress (host HTTP / HTTPS) |
|---------|-------------------|------------------------|-----------------------------|
| dev     | `dev`             | `.kube/kind-dev.yaml`  | 8080 / 8443                 |
| stg     | `stg`             | `.kube/kind-stg.yaml`  | 9080 / 9443                 |
| prod    | `prod`            | `.kube/kind-prod.yaml` | 80 / 443                    |

Kind configs: `infra/kind/<profile>-cluster.yaml`. `setup.sh` writes `.kube/kind-<profile>.yaml`.

---

## Teardown (Kind)

```bash
./infra/kind/destroy.sh dev
```

Removes the Kind cluster and `.kube/kind-dev.yaml`.

---

## Cloud (Terraform)

Day 0 moves to [`infra/terraform/`](./infra/terraform/). After apply:

```bash
source scripts/kubeconfig-setup.sh /path/to/kubeconfig.yaml
./bootstrap/bootstrap.sh prod
```

See [infra/terraform/README.md](./infra/terraform/README.md).

---

## Argo CD UI (after Day 1)

```bash
kubectl port-forward svc/argocd-server -n argocd 8888:80
```

Open http://localhost:8888 — user `admin`. Initial password:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath='{.data.password}' | base64 --decode; echo
```

More detail: [bootstrap/README.md](./bootstrap/README.md).

---

## Day 2 — GitOps (platform on the cluster)

After Day 1, `install.sh` registers the Git repo and optional GitHub creds from [`bootstrap/argocd/repos/`](./bootstrap/argocd/repos/) (env-driven `envsubst`). Push to GitHub, then apply the seed:

```bash
kubectl apply -f gitops/clusters/dev/core.application.yaml
```

| Concept | In this repo | Purpose |
|---------|----------------|--------|
| **AppProject** `core` | `gitops/clusters/dev/core/core.appproject.yaml` | Policy for platform apps |
| **App of Apps** `core-apps` | `gitops/clusters/dev/core.application.yaml` | Syncs AppProject + platform Applications |
| **Application** `ingress-nginx` | `core/applications/ingress-nginx.application.yaml` | Helm ingress-nginx + values in `gitops/apps/` |

Step-by-step: **[gitops/README.md](./gitops/README.md)**.

---

## Documentation

- [Day 0 — Infrastructure](./infra/README.md)
- [Day 1 — Bootstrap (Argo CD)](./bootstrap/README.md)
- [Day 2 — GitOps](./gitops/README.md)
- [Platform lifecycle](./docs/platform-lifecycle.md)

---

## Design principle

```text
Day 0: cluster API + kubeconfig file
       → source kubeconfig-setup.sh <path>
Day 1: bootstrap.sh → install.sh (Helm + repos/)
Day 2: git push → kubectl apply core.application.yaml → core-apps syncs platform from Git
```

You can rename this repository when publishing; the folder model stays the same.
