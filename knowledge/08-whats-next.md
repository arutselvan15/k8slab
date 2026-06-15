# Step 8 — What comes next (not in repo yet)

Finish [steps 0–7](./README.md) first. These topics naturally follow the platform you already built on Kind **dev**.

## Suggested order

| Order | Topic | Why after current repo |
|-------|--------|-------------------------|
| 1 | **Storage labs** in [storage.md](./storage.md) | Stateful workloads need PVCs; OpenEBS fits Day 2 GitOps pattern |
| 2 | **Observability** | Prometheus/Grafana or kube-prometheus-stack as new `core` Applications |
| 3 | **Policy** | Kyverno or Gatekeeper—admission aligns with “platform owns guardrails” |
| 4 | **Secrets** | External Secrets Operator + local/dev backend; never commit secrets |
| 5 | **Day 0 in cloud** | Replace Kind with [`infra/terraform/`](../infra/terraform/); keep Day 1/2 scripts |
| 6 | **Team apps** | Separate AppProject (not `core`) for sample microservices |

## Pattern to reuse

Every new **platform** component should look like existing core apps:

1. Helm values under `gitops/apps/<name>/`
2. Application under `gitops/clusters/dev/core/applications/`
3. Adjust `core.appproject.yaml` and sync-wave if dependencies exist
4. Push Git; let Argo sync—avoid one-off `kubectl apply` except the `core-apps` seed

When you start a topic, add a row to the sequence table in [README.md](./README.md) and optionally a dedicated note file if content grows past one screen.

**Back to index:** [knowledge/README.md](./README.md)
