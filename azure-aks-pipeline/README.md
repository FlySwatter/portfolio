# Azure AKS Deployment with Helm via Azure DevOps

Provisions an AKS cluster with Terraform and deploys a sample app via Helm using an Azure DevOps pipeline.

## Contents
- `main.tf`, `variables.tf`: Terraform AKS cluster
- `helm-chart/`: simple Helm chart for sample app
- `azure-pipelines.yaml`: CI/CD to build image and deploy with Helm

## Quickstart
1. `terraform init && terraform apply`
2. Import repo into Azure DevOps and run the pipeline.
