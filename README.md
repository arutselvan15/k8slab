
# k8slab

Reference layout for **Day 0 / Day 1 / Day 2** Kubernetes platform bootstrap: infrastructure, GitOps controller, then Git-managed workloads.

Built for learning on **Kind** (macOS); structured so **Terraform** and cloud clusters can replace Kind without changing the lifecycle model.

---

## Repository layout

```text
.
├── infra/           # Day 0 — cluster provisioning
├── bootstrap/       # Day 1 — Argo CD
├── gitops/          # Day 2 — platform & apps (empty placeholder)
├── scripts/         # local convenience (not required in enterprise CI)
└── docs/
```

Details: [docs/platform-lifecycle.md](./docs/platform-lifecycle.md)

---

## Quick start (local)

```bash
chmod +x scripts/local-up.sh infra/kind/*.sh bootstrap/bootstrap.sh bootstrap/argocd/install.sh
./scripts/local-up.sh dev
```

Or step by step:

```bash
./infra/kind/setup.sh dev
./bootstrap/bootstrap.sh dev
```

| Profile | kubectl context | Ingress (host HTTP / HTTPS) |
|---------|-----------------|-----------------------------|
| dev     | kind-dev        | 8080 / 8443                 |
| stg     | kind-stg        | 9080 / 9443                 |
| prod    | kind-prod       | 80 / 443                    |

---

## Documentation

- [Day 0 — Infrastructure](./infra/README.md)
- [Day 1 — Bootstrap (Argo CD)](./bootstrap/README.md)
- [Day 2 — GitOps](./gitops/README.md) (placeholder)
- [Platform lifecycle](./docs/platform-lifecycle.md)

---

## Design principle

```text
Day 0: cluster API
Day 1: Argo CD
Day 2: everything else from Git
```

You can rename this repository when publishing; the folder model stays the same.
