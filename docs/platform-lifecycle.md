# Platform lifecycle

Reference model for Kubernetes platform engineering. Same layout applies to a home lab (Kind) and to enterprise cloud (Terraform).

## Phases

```text
Day 0  infra/          Cluster exists (API reachable)
         ↓
Day 1  bootstrap/      GitOps controller (Argo CD) + repo Secrets
         ↓
Day 2  gitops/          Everything else from Git
```

| Phase | Question answered | Tools in this repo |
|-------|-------------------|-------------------|
| **Day 0** | Do we have a cluster? | `infra/terraform/` (placeholder), `infra/kind/` (local) |
| **Day 1** | Can we manage the cluster via Git? | `bootstrap/bootstrap.sh` → `bootstrap/argocd/install.sh` |
| **Day 2** | What runs on the cluster? | `gitops/` (App of Apps + platform apps) |

## What does not belong where

- **Day 0:** VPC, cluster, node pools — not Argo CD, not ingress.
- **Day 1:** Argo CD Helm install, Argo CD repo / repo-creds Secrets — not cert-manager or app stacks.
- **Day 2:** Ingress, cert-manager, monitoring, policies, team apps — not `kind create` or cluster Terraform.

## Environment names

Use **dev**, **stg**, and **prod** consistently:

- Kind configs: `infra/kind/<profile>-cluster.yaml`
- Kubeconfig: `.kube/kind-<profile>.yaml` (Kind); `source scripts/kubeconfig-setup.sh <path>`
- Argo CD Helm overlay: same profile name passed to `bootstrap.sh` / `install.sh`
- GitOps: `gitops/clusters/<profile>/`

Bootstrap pins and secrets: `bootstrap/env/defaults.env` + gitignored `bootstrap.env` (loaded in `install.sh` only).

## Local workflow (macOS)

Kind one-shot (Day 0 + kubeconfig + Day 1):

```bash
./scripts/kind-up.sh dev
```

`kind-up.sh` runs `require-tools.sh kubectl helm envsubst`, then Kind setup, kubeconfig, and `bootstrap.sh`.

Manual (same order):

```bash
./scripts/require-tools.sh kubectl helm envsubst
./infra/kind/setup.sh dev
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
./bootstrap/bootstrap.sh dev
# Day 2: push gitops/, then seed App of Apps:
kubectl apply -f gitops/clusters/dev/core.application.yaml
```

Teardown Day 0 only:

```bash
./infra/kind/destroy.sh dev
```

## Cloud workflow (Terraform)

Day 0 backend differs; **kubeconfig setup + bootstrap stay the same**.

```text
1. terraform apply (infra/terraform/environments/<profile>)
2. kubeconfig path (e.g. .kube/<profile>.yaml)
3. source scripts/kubeconfig-setup.sh <that-path>
4. ./bootstrap/bootstrap.sh <overlay>
```

Shared scripts: `kubeconfig-setup.sh`, `require-tools.sh`, `bootstrap/`.
