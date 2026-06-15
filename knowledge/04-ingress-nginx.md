# Step 4 — ingress-nginx (platform ingress)

**Question answered:** “How does HTTP/S traffic reach services inside the cluster on Kind dev?”

**Depends on:** [Step 3 — Day 2 GitOps core](./03-day2-gitops-core.md) (`git push`, `./scripts/gitops-start.sh dev`).

**Next in sequence:** [Step 5 — cert-manager](./05-cert-manager.md) (TLS CRDs and controllers).

---

## Mental model

```text
Browser / curl
      ↓
Host localhost:8080 or :8443     (Kind extraPortMappings)
      ↓
Kind node ports 80 / 443
      ↓
ingress-nginx controller (hostPort)
      ↓
Ingress resource → Service → Pod
```

Without an ingress controller, `Ingress` objects do nothing. This repo installs **ingress-nginx** as the first platform app after the AppProject.

## How it is installed (Day 2 GitOps)

| Item | Value |
|------|--------|
| Argo Application | `ingress-nginx` |
| Sync wave | `10` (before cert-manager) |
| Manifest | [`gitops/clusters/dev/core/applications/ingress-nginx.application.yaml`](../gitops/clusters/dev/core/applications/ingress-nginx.application.yaml) |
| Helm chart | `ingress-nginx` from `https://kubernetes.github.io/ingress-nginx` |
| Values | [`gitops/apps/ingress-nginx/values.yaml`](../gitops/apps/ingress-nginx/values.yaml) (multi-source `$values/...`) |
| Target namespace | `ingress-nginx` |

Argo **core-apps** syncs the Application CR; Argo **ingress-nginx** syncs the Helm release.

## Kind dev networking (why not port 443 on the Mac)

[`infra/kind/dev-cluster.yaml`](../infra/kind/dev-cluster.yaml) maps:

```text
host 8080 → node 80
host 8443 → node 443
```

Values enable **hostPort** on the controller so traffic hits the node ports without a cloud LoadBalancer:

```yaml
# gitops/apps/ingress-nginx/values.yaml (concept)
controller:
  ingressClassResource:
    name: nginx
    default: true
  hostPort:
    enabled: true
  service:
    type: ClusterIP
```

Later, Argo CD ingress uses `ingressClassName: nginx` and you open **https://argocd.dev:8443** (step 6).

## Verify

After GitOps sync:

```bash
kubectl get applications -n argocd ingress-nginx
kubectl get pods -n ingress-nginx
kubectl get ingressclass
# expect IngressClass "nginx" (default)
```

## Checklist

- [ ] Ingress controller vs `Ingress` resource
- [ ] Why sync-wave `10` runs before cert-manager
- [ ] Why Kind uses hostPort + 8080/8443 instead of `LoadBalancer`

**Next:** [Step 5 — cert-manager](./05-cert-manager.md)
