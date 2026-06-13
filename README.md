
# Kubernetes Learning Lab

A local Kubernetes platform built on **Kind**, **Argo CD**, **Helm**, and **GitOps** principles.

The goal of this project is to learn Kubernetes, platform engineering, operators, and GitOps using a repeatable, reproducible environment that can be created and destroyed at any time.

---

# Design Principles

This project follows the same high-level pattern used by many platform engineering teams.

```text
Bootstrap
    ↓
ArgoCD
    ↓
Git Repository
    ↓
Everything Else
```

Only the minimum components required to start GitOps are installed manually.

Once Argo CD is running, all cluster components should be deployed and managed from Git.

# Bootstrap

Refer the bootstrap details [here](./bootstrap/README.md)