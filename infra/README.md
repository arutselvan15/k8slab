# Day 0 — Infrastructure

Provision a Kubernetes cluster. Nothing in this layer installs platform applications or GitOps controllers.

## Contents

| Path | Purpose |
|------|---------|
| [`terraform/`](terraform/) | Cloud IaC placeholder (EKS/GKE/AKS) |
| [`kind/`](kind/) | Local Kind clusters for learning on macOS |

## Profiles

Use the same environment names everywhere: **dev**, **stg**, **prod**.

| Profile | Kind cluster name | Kubeconfig file (repo) | Ingress (host HTTP / HTTPS) |
|---------|-------------------|------------------------|-----------------------------|
| dev     | `dev`             | `.kube/kind-dev.yaml`  | 8080 / 8443                 |
| stg     | `stg`             | `.kube/kind-stg.yaml`  | 9080 / 9443                 |
| prod    | `prod`            | `.kube/kind-prod.yaml` | 80 / 443                    |

After `./setup.sh <profile>`, the kubeconfig is at `.kube/kind-<profile>.yaml` (from `kind get kubeconfig`). Do not name the Kind cluster `kind-dev` or the context inside the file becomes `kind-kind-dev`.

## Kind — create cluster

```bash
cd infra/kind
chmod +x setup.sh destroy.sh
./setup.sh dev
```

Re-running `./setup.sh dev` is safe if the cluster already exists; it refreshes the kubeconfig file.

## Kind — kubeconfig + verify

From the repo root (after `setup.sh`):

```bash
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
```

Or use the one-shot wrapper: [`../../scripts/kind-up.sh`](../../scripts/kind-up.sh).

## Kind — destroy cluster

```bash
./destroy.sh dev
```

Also removes `.kube/kind-dev.yaml`.

## Prerequisites

```bash
brew install kind kubectl
```

For Day 1 you also need Helm — see [`../bootstrap/README.md`](../bootstrap/README.md).

## Next

Load kubeconfig, then [Day 1 bootstrap](../bootstrap/README.md):

```bash
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
./bootstrap/bootstrap.sh
```
