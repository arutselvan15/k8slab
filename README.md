
# k8s-platform

Reference layout for **Day 0 / Day 1 / Day 2** Kubernetes platform bootstrap: infrastructure, GitOps controller, then Git-managed workloads.

Built for learning on **Kind** (macOS); structured so **Terraform** can replace Kind in Day 0 without changing Day 1 or Day 2.

---

## Repository layout

```text
.
├── infra/              # Day 0 — cluster provisioning (Kind or Terraform)
├── bootstrap/          # Day 1 — Argo CD
├── gitops/             # Day 2 — platform & apps (placeholder)
├── scripts/
│   ├── kind-up.sh           # Kind Day 0 + kubeconfig + Day 1 (local)
│   └── kubeconfig-setup.sh  # export KUBECONFIG from a file path (any Day 0)
├── .kube/              # kubeconfig files (gitignored; created by Day 0)
└── docs/
```

Details: [docs/platform-lifecycle.md](./docs/platform-lifecycle.md)

---

## How the pieces connect

Profile names (**dev**, **stg**, **prod**) only matter for **Day 0** (which cluster to create and which kubeconfig file to write).

After the cluster exists, Day 1 is always the same two steps:

```text
1. source scripts/kubeconfig-setup.sh <path-to-kubeconfig>
2. ./bootstrap/bootstrap.sh
```

`bootstrap.sh` takes no cluster name — it uses whatever cluster `KUBECONFIG` points at.

| Script | Role |
|--------|------|
| [`scripts/kind-up.sh`](./scripts/kind-up.sh) | Runs Kind `setup.sh`, then steps 1–2 above (local one-shot) |
| [`scripts/kubeconfig-setup.sh`](./scripts/kubeconfig-setup.sh) | **Must be sourced.** Sets `KUBECONFIG` to the file path you pass; runs `kubectl get nodes` |
| [`bootstrap/bootstrap.sh`](./bootstrap/bootstrap.sh) | Installs or upgrades Argo CD via Helm |

Future **`scripts/terraform-up.sh`** will mirror `kind-up.sh`: Terraform apply → kubeconfig path → same steps 1–2.

---

## Quick start (Kind, local)

From the repo root:

```bash
chmod +x scripts/kind-up.sh scripts/kubeconfig-setup.sh \
  infra/kind/*.sh bootstrap/bootstrap.sh bootstrap/argocd/install.sh

./scripts/kind-up.sh dev
```

Or step by step (same order as `kind-up.sh`):

```bash
./infra/kind/setup.sh dev
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
./bootstrap/bootstrap.sh
```

| Profile | Kind cluster name | Kubeconfig file (repo) | Ingress (host HTTP / HTTPS) |
|---------|-------------------|------------------------|-----------------------------|
| dev     | `dev`             | `.kube/kind-dev.yaml`  | 8080 / 8443                 |
| stg     | `stg`             | `.kube/kind-stg.yaml`  | 9080 / 9443                 |
| prod    | `prod`            | `.kube/kind-prod.yaml` | 80 / 443                    |

Kind configs live under `infra/kind/<profile>-cluster.yaml`. `setup.sh` refreshes `.kube/kind-<profile>.yaml` with `kind get kubeconfig`.

---

## Teardown (Kind)

```bash
./infra/kind/destroy.sh dev
```

Removes the Kind cluster and `.kube/kind-dev.yaml`.

---

## Cloud (Terraform)

Day 0 moves to [`infra/terraform/`](./infra/terraform/). After apply, write or export a kubeconfig file, then:

```bash
source scripts/kubeconfig-setup.sh /path/to/kubeconfig.yaml
./bootstrap/bootstrap.sh
```

See [infra/terraform/README.md](./infra/terraform/README.md).

---

## Argo CD UI (after Day 1)

Use the same shell where you sourced `kubeconfig-setup.sh` (or source the kubeconfig path again).

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

## Documentation

- [Day 0 — Infrastructure](./infra/README.md)
- [Day 1 — Bootstrap (Argo CD)](./bootstrap/README.md)
- [Day 2 — GitOps](./gitops/README.md) (placeholder)
- [Platform lifecycle](./docs/platform-lifecycle.md)

---

## Design principle

```text
Day 0: cluster API + kubeconfig file
       → source kubeconfig-setup.sh <path>
Day 1: Argo CD (bootstrap.sh)
Day 2: everything else from Git (gitops/)
```

You can rename this repository when publishing; the folder model stays the same.
