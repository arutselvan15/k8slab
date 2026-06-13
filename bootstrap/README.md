# Day 1 — Bootstrap (GitOps controller)

Install the minimum software needed to manage the cluster from Git: **Argo CD**.

Platform components (ingress, certificates, monitoring, policies) belong in **Day 2** ([`../gitops/`](../gitops/)), not here.

## Layout

```text
bootstrap/
├── bootstrap.sh       # entry: profile name → Argo CD on kind-<profile>
└── argocd/
    ├── install.sh     # Helm install (any kubectl context)
    └── values.yaml
```

## Prerequisites

- Day 0 complete: cluster API reachable (`kubectl get nodes`)
- `helm`, `kubectl`

```bash
brew install kubectl helm
```

## Run Day 1

After [Kind Day 0](../infra/kind/setup.sh):

```bash
cd bootstrap
chmod +x bootstrap.sh argocd/install.sh
./bootstrap.sh dev
```

Re-running upgrades Argo CD via `helm upgrade --install`.

## Argo CD access

Admin password:

```bash
kubectl --context kind-dev get secret argocd-initial-admin-secret \
  -n argocd -o jsonpath='{.data.password}' | base64 --decode; echo
```

UI (use a port that does not clash with ingress — e.g. **8888** on dev):

```bash
kubectl --context kind-dev port-forward svc/argocd-server -n argocd 8888:80
```

Open http://localhost:8888 — user `admin`.

## Cloud clusters

When Terraform replaces Kind, use the kube context from your cloud provider and run:

```bash
./argocd/install.sh <your-context>
```

## Next

Populate [`../gitops/`](../gitops/) (Day 2) and register a root Application from Git.
