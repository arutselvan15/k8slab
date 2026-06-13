# Day 0 — Infrastructure

Provision a Kubernetes cluster. Nothing in this layer installs platform applications or GitOps controllers.

## Contents

| Path | Purpose |
|------|---------|
| [`terraform/`](terraform/) | Cloud IaC placeholder (EKS/GKE/AKS) |
| [`kind/`](kind/) | Local Kind clusters for learning on macOS |

## Profiles

Use the same environment names everywhere: **dev**, **stg**, **prod**.

| Profile | Kind cluster | kubectl context | Ingress (host HTTP / HTTPS) |
|---------|--------------|-----------------|-----------------------------|
| dev     | dev          | kind-dev        | 8080 / 8443                 |
| stg     | stg          | kind-stg        | 9080 / 9443                 |
| prod    | prod         | kind-prod       | 80 / 443                    |

Kind sets context to `kind-<name>`. Do not name the cluster `kind-dev` or the context becomes `kind-kind-dev`.

## Kind — create cluster

```bash
cd infra/kind
chmod +x setup.sh destroy.sh
./setup.sh dev
kubectl --context kind-dev get nodes
```

Re-running `./setup.sh dev` is safe if the cluster already exists.

## Kind — destroy cluster

```bash
./destroy.sh dev
```

## Prerequisites

```bash
brew install kind kubectl
```

For Day 1 you also need Helm — see [`../bootstrap/README.md`](../bootstrap/README.md).

## Next

After Day 0, run [Day 1 bootstrap](../bootstrap/README.md) to install Argo CD.
