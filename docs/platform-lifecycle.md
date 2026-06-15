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
| **Day 2** | What runs on the cluster? | `gitops/` + [`scripts/gitops-start.sh`](../scripts/gitops-start.sh) |

## What does not belong where

- **Day 0:** VPC, cluster, node pools — not Argo CD, not ingress.
- **Day 1:** Argo CD Helm install, Argo CD repo / repo-creds Secrets — not cert-manager or app stacks.
- **Day 2:** Ingress, cert-manager, **core-certificates** (platform TLS CRs), monitoring, policies, team apps — not `kind create` or cluster Terraform.

## Environment names

Use **dev**, **stg**, and **prod** consistently:

- Kind configs: `infra/kind/<profile>-cluster.yaml`
- Kubeconfig: `.kube/kind-<profile>.yaml` (Kind); `source scripts/kubeconfig-setup.sh <path>`
- Argo CD Helm overlay: same profile name passed to `bootstrap.sh` / `install.sh`
- GitOps: `gitops/clusters/<profile>/`

Bootstrap pins and secrets: `bootstrap/env/defaults.env` + gitignored `bootstrap.env` (loaded in `install.sh` only).

## Local workflow (macOS)

Kind — Day 0 + Day 1 only:

```bash
./scripts/kind-up.sh dev
```

Day 2 (after push to Git):

```bash
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
./scripts/gitops-start.sh dev
```

Manual (full order):

```bash
./scripts/require-tools.sh kubectl helm envsubst
./infra/kind/setup.sh dev
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
./bootstrap/bootstrap.sh dev
git push   # gitops on GitHub
./scripts/gitops-start.sh dev
```

**Dev UI:** `127.0.0.1 argocd.dev` in `/etc/hosts` → **https://argocd.dev:8443** (Kind node port 8443). See [bootstrap/README.md](../bootstrap/README.md) and [gitops/README.md](../gitops/README.md).

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
5. ./scripts/gitops-start.sh <profile>   # after gitops push
```

Shared scripts: `kubeconfig-setup.sh`, `require-tools.sh`, `bootstrap/`.
