# Day 2 — GitOps

**Reserved.** Platform and application workloads will be declared here and synced by Argo CD.

Nothing in Day 2 is installed by shell scripts or Terraform after bootstrap is complete.

## Planned layout

```text
gitops/
├── apps/                 # shared bases (Helm/Kustomize wrappers)
└── clusters/
    ├── dev/
    ├── stg/
    └── prod/
```

Typical flow:

1. Add an Argo CD `Application` (or App-of-Apps root) under `gitops/clusters/<profile>/`.
2. Point Argo CD at this repository path.
3. Let Argo CD reconcile; do not `helm install` platform charts by hand.

## Status

This directory is intentionally empty while Day 0 and Day 1 are validated locally.

See [`../docs/platform-lifecycle.md`](../docs/platform-lifecycle.md) for how the phases fit together.
