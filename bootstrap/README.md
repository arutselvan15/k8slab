# Bootstrap Guide

This document covers the initial bootstrap process for the Kubernetes GitOps Learning Lab.

The purpose of bootstrapping is to create a Kubernetes cluster and install Argo CD so that all future cluster components can be managed through GitOps.

---

# Bootstrap Architecture

```text
bootstrap/kind/setup.sh
        ↓
Kind Cluster
        ↓
bootstrap/argocd/install.sh
        ↓
ArgoCD
        ↓
GitOps manages everything else
```

Only two components are installed manually:

1. Kind (Kubernetes cluster)
2. Argo CD (GitOps controller)

Everything else will eventually be deployed through Argo CD.

---

# Prerequisites

Install the required tools:

```bash
brew install kind
brew install kubectl
brew install helm
brew install git
```

Verify installation:

```bash
kind version
kubectl version --client
helm version
git --version
```

---

# Bootstrap Directory Structure

```text
bootstrap/
├── kind/
│   ├── cluster.yaml
│   └── setup.sh
│
└── argocd/
    ├── install.sh
    └── values.yaml
```

## kind/

Contains files required to create the local Kubernetes cluster.

### cluster.yaml

Defines the Kind cluster configuration.

### setup.sh

Creates the Kubernetes cluster using the Kind configuration.

---

## argocd/

Contains files required to install Argo CD.

### values.yaml

Custom Helm values used during installation.

### install.sh

Installs or upgrades Argo CD using Helm.

---

# Step 1 - Create the Kind Cluster

Navigate to the Kind bootstrap directory:

```bash
cd bootstrap/kind
```

Create the cluster:

```bash
./setup.sh
```

Example output:

```text
Creating cluster "dev" ...
```

Verify the cluster:

```bash
kubectl get nodes
```

Expected:

```text
NAME                STATUS
dev-control-plane   Ready
```

Verify Kubernetes connectivity:

```bash
kubectl cluster-info
```

Example:

```text
Kubernetes control plane is running at https://127.0.0.1:xxxxx
```

At this point a working Kubernetes cluster is available.

---

# Step 2 - Install Argo CD

Navigate to the Argo CD bootstrap directory:

```bash
cd ../argocd
```

Install Argo CD:

```bash
./install.sh
```

The installation script performs the following actions:

1. Adds the Argo Helm repository
2. Updates Helm repositories
3. Creates the `argocd` namespace
4. Installs or upgrades Argo CD
5. Waits for deployment completion

---

# Verify Argo CD Installation

Check all Argo CD pods:

```bash
kubectl get pods -n argocd
```

Expected output:

```text
argocd-application-controller
argocd-applicationset-controller
argocd-repo-server
argocd-server
argocd-redis
```

All pods should eventually show:

```text
Running
```

---

# Verify Helm Installation

Confirm Helm is managing Argo CD:

```bash
helm list -n argocd
```

Expected:

```text
NAME     NAMESPACE
argocd   argocd
```

---

# Retrieve Initial Admin Password

Argo CD generates an initial admin password stored in a Kubernetes Secret.

Retrieve it:

```bash
kubectl get secret argocd-initial-admin-secret \
  -n argocd \
  -o jsonpath='{.data.password}' \
  | base64 --decode

echo
```

Save this password for login.

---

# Access Argo CD

Create a local port-forward:

```bash
kubectl port-forward \
  svc/argocd-server \
  -n argocd \
  8080:80
```

Open your browser:

```text
http://localhost:8080
```

Login using:

```text
Username: admin
Password: <retrieved password>
```

---

# Current State

After completing bootstrap:

```text
Mac
│
├── Kind Cluster
│
└── ArgoCD
```

The cluster is now ready for GitOps.

Future components such as:

- ingress-nginx
- cert-manager
- external-secrets
- dashboard
- monitoring
- Kubeflow

will be installed and managed through Argo CD rather than manually with `kubectl apply` or `helm install`.

---

# Cleanup

Delete the cluster:

```bash
kind delete cluster --name dev
```

Verify:

```bash
kind get clusters
```

The cluster should no longer appear in the list.

---

# Next Step

The next milestone is creating a GitOps repository structure and a Root Application (App-of-Apps pattern) so Argo CD can begin managing cluster infrastructure directly from Git.