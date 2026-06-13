
# Kubernetes Learning Lab

Local Kubernetes on **Kind**, **Argo CD**, **Helm**, and **GitOps** — for learning on a Mac. Clusters: **dev**, **stg**, and **prod** (unique host ingress ports per profile).

---

## Bootstrap

```bash
chmod +x bootstrap/bootstrap.sh bootstrap/kind/*.sh bootstrap/argocd/install.sh
./bootstrap/bootstrap.sh dev   # or stg | prod — safe to re-run
```

Details: [bootstrap/README.md](./bootstrap/README.md)

---

## Design

```text
Bootstrap (Kind + Argo CD)
    ↓
Git repository
    ↓
Everything else (GitOps)
```
