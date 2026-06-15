# Step 5 — cert-manager (TLS automation)

**Question answered:** “Who creates and renews TLS Secrets from declarative config?”

**Depends on:** [Step 4 — ingress-nginx](./04-ingress-nginx.md) (optional for cert-manager itself; ingress is needed later for Argo UI).

**Next in sequence:** [Step 6 — Argo CD ingress & TLS](./06-argocd-ingress-tls.md) (`Certificate` + Helm ingress).

---

## Mental model

```text
You declare:          cert-manager runs:
ClusterIssuer    →    knows how to sign (CA / ACME / selfSigned)
Certificate      →    orders cert for dnsNames → Kubernetes Secret
```

Ingress (and other workloads) **reference** the Secret by name (`tls.secretName`). cert-manager **fills** the Secret; it does not configure ingress rules.

## How it is installed (Day 2 GitOps)

| Item | Value |
|------|--------|
| Argo Application | `cert-manager` |
| Sync wave | `20` (after ingress-nginx) |
| Manifest | [`gitops/clusters/dev/core/applications/cert-manager.application.yaml`](../gitops/clusters/dev/core/applications/cert-manager.application.yaml) |
| Helm chart | `cert-manager` from `https://charts.jetstack.io` |
| Values | [`gitops/apps/cert-manager/values.yaml`](../gitops/apps/cert-manager/values.yaml) |
| Target namespace | `cert-manager` |

Values install CRDs with the chart (required before any `Certificate`):

```yaml
crds:
  enabled: true
  keep: true
```

## Why cert-manager is separate from “certificate YAML”

Platform **Helm apps** live under `core/applications/` and are synced by **core-apps**.

**cert-manager CRs** (`ClusterIssuer`, `Certificate`, …) live under `core/certificates/` and are synced by Application **`core-certificates`** (wave `25`)—see step 6.

If you put `Certificate` YAML under `applications/`, Argo may apply them **before** CRDs exist → sync errors.

## Verify

```bash
kubectl get applications -n argocd cert-manager
kubectl get pods -n cert-manager
kubectl api-resources | grep cert-manager
# Certificate, ClusterIssuer, ...
```

Do **not** expect Argo UI TLS yet; that needs step 6 (`Certificate` + Helm ingress).

## Checklist

- [ ] cert-manager controller vs `Certificate` / `ClusterIssuer` CRs
- [ ] Why CRDs must be installed before `core-certificates` syncs
- [ ] Secret output is consumed by ingress or pods—not by cert-manager UI alone

**Next:** [Step 6 — Argo CD ingress & TLS](./06-argocd-ingress-tls.md)
