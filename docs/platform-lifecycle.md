# Platform lifecycle

Reference model for Kubernetes platform engineering. Same layout applies to a home lab (Kind) and to enterprise cloud (Terraform).

## Phases

```text
Day 0  infra/          Cluster exists (API reachable)
         ↓
Day 1  bootstrap/      GitOps controller (Argo CD)
         ↓
Day 2  gitops/          Everything else from Git
```

| Phase | Question answered | Tools in this repo |
|-------|-------------------|-------------------|
| **Day 0** | Do we have a cluster? | `infra/terraform/` (placeholder), `infra/kind/` (local) |
| **Day 1** | Can we manage the cluster via Git? | `bootstrap/argocd/` |
| **Day 2** | What runs on the cluster? | `gitops/` (App of Apps + platform apps) |

## What does not belong where

- **Day 0:** VPC, cluster, node pools — not Argo CD, not ingress.
- **Day 1:** Argo CD (and optionally a single root `Application` manifest later) — not cert-manager or app stacks.
- **Day 2:** Ingress, cert-manager, monitoring, policies, team apps — not `kind create` or cluster Terraform.

## Environment names

Use **dev**, **stg**, and **prod** consistently:

- Kind configs: `infra/kind/<profile>-cluster.yaml`
- Kubeconfig file: path from Day 0 (e.g. `.kube/kind-<profile>.yaml` from Kind); load with `source scripts/kubeconfig-setup.sh <path>`
- Future GitOps: `gitops/clusters/<profile>/`

## Local workflow (macOS)

Kind one-shot (Day 0 + kubeconfig + Day 1):

```bash
./scripts/kind-up.sh dev
```

Same steps manually (same order as `kind-up.sh`):

```bash
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

Add a sibling script when Terraform is ready, e.g. `scripts/terraform-up.sh <profile>`:

```text
1. terraform apply (infra/terraform/environments/<profile>)
2. Write or reference kubeconfig path (Terraform output → file, e.g. .kube/<profile>.yaml)
3. source scripts/kubeconfig-setup.sh <that-path>
4. ./bootstrap/bootstrap.sh <overlay>
```

`kind-up.sh` and `terraform-up.sh` are thin wrappers; shared pieces are `kubeconfig-setup.sh` and `bootstrap/`.
