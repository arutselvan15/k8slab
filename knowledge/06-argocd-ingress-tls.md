# Step 6 — Argo CD ingress & TLS (dev UI)

**Question answered:** “How do I open Argo over HTTPS on Kind, and why is bootstrap run twice?”

**Depends on:**

- [Step 4 — ingress-nginx](./04-ingress-nginx.md) — routes traffic to `argocd-server`
- [Step 5 — cert-manager](./05-cert-manager.md) — CRDs + controller for `Certificate`

This step connects **GitOps TLS** (Secret material) with **Day 1 Helm** (Argo server ingress wiring).

---

## End state (dev)

| Item | Value |
|------|--------|
| URL | https://argocd.dev:8443 |
| `/etc/hosts` | `127.0.0.1 argocd.dev` |
| TLS Secret | `argocd-server-tls` in namespace `argocd` |
| Ingress class | `nginx` |

Browser port **8443** = Kind host mapping to node **443** (see step 4).

## Two owners (remember this)

| Concern | Owner | What |
|---------|--------|------|
| TLS Secret **contents** | Day 2 GitOps — **`core-certificates`** | `ClusterIssuer` + `Certificate` → Secret |
| Argo **Ingress** object (host, class, `secretName`) | Day 1 Helm — [`bootstrap/argocd/values/overlays/dev.yaml`](../bootstrap/argocd/values/overlays/dev.yaml) | Enables ingress, points at Secret name |

Helm: *“mount Secret `argocd-server-tls` on ingress.”*  
GitOps: *“create that Secret via cert-manager.”*

```text
core-certificates (GitOps)          bootstrap.sh dev (Helm) — after cert Ready
──────────────────────────          ─────────────────────────────────────────
ClusterIssuer selfsigned       →    (issuer must exist first)
Certificate argocd-server-tls  →    writes Secret argocd-server-tls
                                    ↓ Certificate Ready
./bootstrap/bootstrap.sh dev   →    server.ingress enabled + secretName set
```

First bootstrap (during `kind-up.sh`) can run **before** the Secret exists. **Re-run** bootstrap after the Certificate is **Ready**.

## GitOps: Application `core-certificates`

| Item | Value |
|------|--------|
| Sync wave | `25` (after cert-manager) |
| Manifest | [`gitops/clusters/dev/core/applications/core-certificates.application.yaml`](../gitops/clusters/dev/core/applications/core-certificates.application.yaml) |
| Git path | [`gitops/clusters/dev/core/certificates/`](../gitops/clusters/dev/core/certificates/) |

Key files:

| File | Role |
|------|------|
| [`clusterissuer-selfsigned.yaml`](../gitops/clusters/dev/core/certificates/clusterissuer-selfsigned.yaml) | Dev-only issuer (not public CA trust) |
| [`argocd-server-certificate.yaml`](../gitops/clusters/dev/core/certificates/argocd-server-certificate.yaml) | `dnsNames: [argocd.dev]`, `secretName: argocd-server-tls` |

`secretName` and DNS must match the Helm overlay (`hostname`, `server.ingress.secretName`).

## Helm: Argo server ingress (Day 1 overlay)

[`bootstrap/argocd/values/overlays/dev.yaml`](../bootstrap/argocd/values/overlays/dev.yaml):

- `server.ingress.enabled: true`, `ingressClassName: nginx`, `hostname: argocd.dev`
- `server.ingress.tls: true`, `secretName: argocd-server-tls`
- `configs.params.server.insecure: true` — TLS terminates at **ingress**; ingress uses HTTP to the Argo pod (`backend-protocol: HTTP`)

## Order of operations

1. Steps 0–3: cluster, Argo, `git push`, `./scripts/gitops-start.sh dev`
2. Wait for sync waves 10 → 20 → 25 (ingress, cert-manager, certs)
3. Confirm Certificate:

   ```bash
   kubectl get applications -n argocd
   kubectl get certificate -n argocd argocd-server-tls
   # STATUS Ready
   ```

4. `./bootstrap/bootstrap.sh dev`
5. Open https://argocd.dev:8443 (admin password: step 2 guide)

Until step 6 completes, use port-forward from [02-day1-bootstrap.md](./02-day1-bootstrap.md).

## Troubleshooting

| Symptom | Likely cause |
|---------|----------------|
| `Certificate` CRD not found | CR YAML under `applications/` instead of `certificates/` |
| Certs listed under `core-apps` | Wrong sync path; use `core/applications/` only for core-apps |
| Ingress 404 | Step 4 not Synced or wrong `ingressClassName` |
| Browser TLS error | Certificate not Ready, or bootstrap not re-run after Ready |
| Wrong cert name | `secretName` mismatch between Certificate and Helm overlay |

## Checklist

- [ ] `core-certificates` vs `cert-manager` Application roles
- [ ] Why TLS YAML is GitOps but ingress **enable** is Helm
- [ ] Why bootstrap runs again after `Certificate` Ready
- [ ] TLS at ingress vs `server.insecure` to the pod

**Next:** [Step 7 — Storage fundamentals](./storage.md)
