# Step 2 — Day 1: Bootstrap (Argo CD)

**Question answered:** “Can we manage the cluster from Git?”

Day 1 installs the **GitOps controller** and gives it permission to clone your platform repo. It does **not** install ingress-nginx, cert-manager, or app stacks.

## Chicken and egg

Argo CD syncs from Git, but Argo CD itself must exist first. So:

- **Day 1 (shell + Helm):** install Argo CD, apply repo Secrets
- **Day 2 (Git + one seed apply):** everything else

```text
Human + Helm          →  Argo CD running
Human + kubectl       →  repo-creds + repository Secrets
Git + gitops-start    →  Applications sync platform
```

## What runs

```text
./bootstrap/bootstrap.sh dev
        └── bootstrap/argocd/install.sh dev
              ├── load bootstrap/env/ (defaults.env + bootstrap.env)
              ├── helm upgrade --install argo-cd (chart pin in defaults.env)
              ├── apply argocd/repos/repo-creds.*.yaml
              └── apply argocd/repos/repo.*.yaml
```

Env is loaded **only** in `install.sh`, not in `bootstrap.sh`.

## Configuration map

| Concern | Where |
|---------|--------|
| Chart version | `bootstrap/env/defaults.env` → `ARGO_CD_CHART_VERSION` |
| Helm values (base + overlay) | `bootstrap/argocd/values/base.yaml`, `overlays/dev.yaml` |
| Git URL (must match GitOps) | `GIT_REPO_URL` in defaults + `bootstrap/argocd/repos/repo.k8s-platform.yaml` |
| Private GitHub | `bootstrap.env` → PAT or SSH templates in `repos/` |

## What deliberately stays in bootstrap (not GitOps)

| Item | Reason |
|------|--------|
| Argo CD Helm release | Controller must exist before any Application |
| Repository / repo-creds Secrets | Argo needs clone access before first sync |
| Enabling Argo **ingress** in Helm | Chart is Day 1; **TLS Secret contents** are Day 2 GitOps (steps [5](./05-cert-manager.md)–[6](./06-argocd-ingress-tls.md)) |

Platform apps belong in **`gitops/`**, not in bootstrap scripts.

## Verify Day 1

```bash
source scripts/kubeconfig-setup.sh .kube/kind-dev.yaml
kubectl get pods -n argocd
```

Before Day 2 sync, UI access is usually port-forward:

```bash
kubectl port-forward svc/argocd-server -n argocd 8888:80
```

Admin user: **`admin`**. Password from `ARGOCD_ADMIN_PASSWORD` in `bootstrap.env`, or:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath='{.data.password}' | base64 --decode; echo
```

## Checklist

- [ ] Difference between Day 1 and Day 2
- [ ] Why `GIT_REPO_URL` must match `gitops/.../repoURL`
- [ ] Why ingress can be “configured” in Helm but not usable until steps 4–6

**Next:** [Step 3 — Day 2 GitOps core](./03-day2-gitops-core.md)