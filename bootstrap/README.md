# Bootstrap Guide

Create a local Kind cluster and install Argo CD. Run one cluster at a time on your Mac, or use separate profiles concurrently (unique host ports).

Everything after bootstrap should be managed with GitOps through Argo CD.

---

## Architecture

```text
bootstrap/bootstrap.sh <profile>
        ↓
Kind cluster (create if missing)
        ↓
Argo CD (helm upgrade --install)
        ↓
GitOps manages everything else
```

---

## Prerequisites

```bash
brew install kind kubectl helm git
```

---

## Directory structure

```text
bootstrap/
├── bootstrap.sh          # Kind + Argo CD (idempotent)
├── kind/
│   ├── dev-cluster.yaml
│   ├── stg-cluster.yaml
│   ├── prod-cluster.yaml
│   ├── setup.sh
│   └── destroy.sh
└── argocd/
    ├── install.sh
    └── values.yaml
```

---

## Bootstrap (recommended)

From the repo root or `bootstrap/`:

```bash
chmod +x bootstrap/bootstrap.sh bootstrap/kind/*.sh bootstrap/argocd/install.sh
./bootstrap/bootstrap.sh dev    # or stg | prod
```

Re-running the same command is safe: it skips Kind creation if the cluster exists and upgrades Argo CD via Helm.

| Profile | Kind cluster name | kubectl context | Ingress (host HTTP / HTTPS) |
|---------|-------------------|-----------------|-----------------------------|
| dev     | dev               | kind-dev        | 8080 / 8443                 |
| stg     | stg               | kind-stg        | 9080 / 9443                 |
| prod    | prod              | kind-prod       | 80 / 443                    |

Kind sets the kubeconfig context to `kind-<name>` — do not put `kind-` in the cluster name itself.

---

## Manual steps (optional)

Kind only:

```bash
cd bootstrap/kind && ./setup.sh dev
```

Argo CD only (current context or explicit):

```bash
cd bootstrap/argocd && ./install.sh kind-dev
```

---

## Argo CD access

Initial admin password:

```bash
kubectl --context kind-dev get secret argocd-initial-admin-secret \
  -n argocd -o jsonpath='{.data.password}' | base64 --decode; echo
```

Port-forward (e.g. port 8888 on **dev** to avoid clashing with ingress on 8080):

```bash
kubectl --context kind-dev port-forward svc/argocd-server -n argocd 8888:80
```

Open http://localhost:8888 (user `admin`).

---

## Cleanup

```bash
./bootstrap/kind/destroy.sh dev    # or stg | prod
kind get clusters
```

---

## Next step

Add a GitOps layout and a root Application (App-of-Apps) so Argo CD syncs cluster add-ons from Git.
