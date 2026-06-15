# Step 1 — Day 0: Kubernetes cluster (Kind)

**Question answered:** “Is there a cluster and can `kubectl` talk to it?”

Nothing in Day 0 installs Argo CD, ingress, or cert-manager.

## Mental model

```text
Your Mac
   │
   └── Docker
         └── Kind “dev” cluster (control-plane node)
                   └── Kubernetes API
```

Kind runs real Kubernetes inside a container. It is enough to learn GitOps, ingress, and TLS the same way you would on EKS/GKE—only networking and storage differ.

## What this repo creates

| Artifact | Path |
|----------|------|
| Cluster config | [`infra/kind/dev-cluster.yaml`](../infra/kind/dev-cluster.yaml) |
| Create script | [`infra/kind/setup.sh`](../infra/kind/setup.sh) |
| Kubeconfig output | `.kube/kind-dev.yaml` (gitignored locally) |

Dev Kind maps **host** ports to the node’s ingress ports:

```yaml
# infra/kind/dev-cluster.yaml (concept)
hostPort: 8080  → containerPort: 80
hostPort: 8443  → containerPort: 443
```

That is why the Argo UI later is **https://argocd.dev:8443**, not `:443`.

## Commands

**Shortcut (Day 0 + Day 1 in one script):**

```bash
./scripts/kind-up.sh dev
```

**Day 0 only:**

```bash
./infra/kind/setup.sh dev
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
kubectl get nodes
```

Re-running `setup.sh` is safe: it skips create if the cluster exists and refreshes kubeconfig.

## Cloud note

[`infra/terraform/`](../infra/terraform/) is a placeholder for real Day 0. After `terraform apply`, you still use the same kubeconfig script and Day 1/2 scripts—only the kubeconfig path changes.

## Teardown

```bash
./infra/kind/destroy.sh dev
```

Removes the cluster and `.kube/kind-dev.yaml`.

## Checklist — you understood Day 0 when you can explain

- [ ] What Kind is vs “Kubernetes in the cloud”
- [ ] Where kubeconfig lives and why `KUBECONFIG` must be set
- [ ] Why dev uses host ports 8080 and 8443

**Next:** [Step 2 — Day 1 bootstrap](./02-day1-bootstrap.md) (or you already ran it via `kind-up.sh`)
