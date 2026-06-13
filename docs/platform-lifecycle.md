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
| **Day 2** | What runs on the cluster? | `gitops/` (empty for now) |

## What does not belong where

- **Day 0:** VPC, cluster, node pools — not Argo CD, not ingress.
- **Day 1:** Argo CD (and optionally a single root `Application` manifest later) — not cert-manager or app stacks.
- **Day 2:** Ingress, cert-manager, monitoring, policies, team apps — not `kind create` or cluster Terraform.

## Environment names

Use **dev**, **stg**, and **prod** consistently:

- Kind configs: `infra/kind/<profile>-cluster.yaml`
- kubectl context (Kind): `kind-<profile>`
- Future GitOps: `gitops/clusters/<profile>/`

## Local workflow (macOS)

One-shot (learning convenience):

```bash
./scripts/local-up.sh dev
```

Explicit phases:

```bash
./infra/kind/setup.sh dev
./bootstrap/bootstrap.sh dev
# Day 2: commit manifests under gitops/ and sync with Argo CD
```

Teardown Day 0 only:

```bash
./infra/kind/destroy.sh dev
```

## Enterprise workflow

1. CI/CD or platform team applies `infra/terraform/environments/<profile>`.
2. Pipeline or break-glass script runs `bootstrap/argocd/install.sh` with the cloud kube context.
3. Platform team merges to `gitops/`; Argo CD reconciles Day 2.

Kind is a **local substitute** for Terraform in Day 0, not a different lifecycle.
