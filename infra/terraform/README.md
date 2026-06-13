# Terraform (Day 0)

Placeholder for cloud cluster provisioning (EKS, GKE, AKS, etc.).

## Role in the platform model

| Phase | This directory |
|-------|----------------|
| **Day 0** | Define and apply infrastructure so a Kubernetes API exists |
| **Day 1** | Not here — see [`../bootstrap/`](../bootstrap/) |
| **Day 2** | Not here — see [`../gitops/`](../gitops/) |

## Local development

On a Mac, [`../kind/`](../kind/) stands in for Terraform: same **Day 0** slot, different tooling.

## When you add Terraform

Suggested layout:

```text
terraform/
├── modules/
│   └── eks/              # example
├── environments/
│   ├── dev/
│   ├── stg/
│   └── prod/
└── README.md
```

Wire each environment to the same profile names (`dev`, `stg`, `prod`) used in Kind and in future GitOps paths under `gitops/clusters/`.

## Outputs

Terraform should expose at minimum:

- `cluster_name`
- `kubeconfig` or instructions for CI to authenticate

Day 1 bootstrap then targets that cluster context the same way `bootstrap/bootstrap.sh` uses `kind-<profile>` today.
