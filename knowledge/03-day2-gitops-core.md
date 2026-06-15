# Step 3 — Day 2: GitOps and core platform

**Question answered:** “What runs on the cluster, and who keeps it in sync?”

After Day 1, Argo CD is idle until you (1) **push** manifests to GitHub and (2) apply the **seed** Application.

## Critical detail: Argo clones GitHub, not your laptop

Edits under `gitops/` do nothing on the cluster until:

```bash
git push origin main
```

Argo uses the remote URL registered in Day 1.

## The seed (only manual Day 2 kubectl)

```bash
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
./scripts/gitops-start.sh dev
```

This applies [`gitops/clusters/dev/core.application.yaml`](../gitops/clusters/dev/core.application.yaml), which creates Application **`core-apps`**.

Do **not** hand-apply files under `core/applications/` or `core/certificates/`—`core-apps` and sibling apps sync those paths.

## App of Apps

```text
Application "core-apps"  (project: default)
   source: gitops/clusters/dev/core/applications/
        │
        ├── sync-wave -1   AppProject "core"
        ├── sync-wave 10   Application "ingress-nginx"
        ├── sync-wave 20   Application "cert-manager"
        └── sync-wave 25   Application "core-certificates"
```

| Argo kind | Name | Role |
|-----------|------|------|
| AppProject | `core` | Policy: which repos/namespaces platform apps may use |
| Application | `core-apps` | Registers child Applications + AppProject |
| Application | `ingress-nginx`, `cert-manager`, … | Each installs one platform component |
| Application | `core-certificates` | Syncs **cert-manager CRs** only |

## Two Git paths (easy to confuse)

| Application | Syncs path | Contains |
|-------------|------------|----------|
| `core-apps` | `core/applications/` | AppProject, Application YAML only |
| `core-certificates` | `core/certificates/` | ClusterIssuer, Certificate, … |

Certificate manifests must **not** live under `applications/`, or Argo may try to apply them before cert-manager CRDs exist.

Helm **values** live in [`gitops/apps/`](../gitops/apps/); child apps use **multi-source** apps (`chart` + `$values/...` ref).

## Repository layout (dev)

```text
gitops/
├── apps/                          # values only
│   ├── ingress-nginx/values.yaml
│   └── cert-manager/values.yaml
└── clusters/dev/
    ├── core.application.yaml      # seed
    └── core/
        ├── applications/          # core-apps
        └── certificates/          # core-certificates
```

## Verify

```bash
kubectl get applications -n argocd
# expect: core-apps, ingress-nginx, cert-manager, core-certificates → Synced
```

## Adding another core component (pattern you will reuse)

1. `gitops/apps/<name>/values.yaml`
2. `gitops/clusters/dev/core/applications/<name>.application.yaml` (`project: core`, set `sync-wave`)
3. Update `core.appproject.yaml` if new repo or namespace
4. `git push` — `core-apps` picks up the new Application

## Checklist

- [ ] Why `gitops-start.sh` exists (bootstrap vs seed)
- [ ] AppProject vs Application vs App of Apps
- [ ] Why certificates are a separate Application and path
- [ ] Sync waves: ingress before cert-manager before certs

**Next:** [Step 4 — ingress-nginx](./04-ingress-nginx.md), then [5](./05-cert-manager.md), [6](./06-argocd-ingress-tls.md)
