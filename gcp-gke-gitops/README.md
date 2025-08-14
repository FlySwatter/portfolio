# GKE GitOps with ArgoCD + Kustomize

Terraform provisions a minimal GKE cluster. Kustomize manages base/overlays. A GitHub Actions workflow updates ArgoCD.

## Contents
- `main.tf`, `variables.tf`: Terraform GKE
- `kustomize/`: base & overlays for a sample app
- `.github/workflows/deploy.yaml`: Patch ArgoCD app (sample)
