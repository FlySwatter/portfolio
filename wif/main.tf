module "wif" {
  source             = "../../modules/wif_pool"
  project_id         = var.project_id
  pool_id            = var.pool_id
  provider_id        = var.provider_id
  openshift_oidc_url = var.openshift_oidc_url
}

module "team_sas" {
  source               = "../../modules/team_sa"
  env_name             = var.env_name
  project_id           = var.project_id
  pool_id              = var.pool_id
  provider_id          = var.provider_id
  teams                = var.teams
}


variables.tf
variable "project_id" {}
variable "pool_id" {}
variable "provider_id" {}
variable "openshift_oidc_url" {}
variable "env_name" {}

variable "teams" {
  type = map(object({
    gcp_service_accounts = list(object({
      name  = string
      roles = list(string)
    }))
  }))
}

terraform.tfvars
project_id         = "gcp-lab-id"
pool_id            = "wif-lab-pool"
provider_id        = "wif-lab-provider"
openshift_oidc_url = "https://openshift-lab.example.com"
env_name           = "lab"

teams = {
  team-a = {
    gcp_service_accounts = [
      {
        name  = "team-a-storage"
        roles = ["roles/storage.objectViewer"]
      }
    ]
  }

  team-b = {
    gcp_service_accounts = [
      {
        name  = "team-b-logs"
        roles = ["roles/logging.viewer"]
      }
    ]
  }
}
6:05
backend.tf
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "wif/lab"
  }
}




modules/wif_pool/main.tf
resource "google_iam_workload_identity_pool" "wif_pool" {
  project                    = var.project_id
  location                   = "global"
  workload_identity_pool_id = var.pool_id
  display_name              = "WIF Pool for ${var.pool_id}"
}

resource "google_iam_workload_identity_pool_provider" "oidc_provider" {
  project                            = var.project_id
  location                           = "global"
  workload_identity_pool_id          = google_iam_workload_identity_pool.wif_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "OIDC Provider for OpenShift"

  oidc {
    issuer_uri = var.openshift_oidc_url
  }

  attribute_mapping = {
    "google.subject"           = "assertion.sub"
    "attribute.k8s_sa_name"    = "assertion.kubernetes.io/serviceaccount.name"
    "attribute.k8s_ns"         = "assertion.kubernetes.io/serviceaccount.namespace"
  }
}

modules/wif_pool/variables.tf

variable "project_id" {}
variable "pool_id" {}
variable "provider_id" {}
variable "openshift_oidc_url" {}


modules/team_sa/main.tf
resource "google_service_account" "team_sas" {
  for_each = {
    for team_name, config in var.teams :
    for sa in config.gcp_service_accounts :
    "${team_name}-${sa.name}" => {
      team = team_name
      name = sa.name
    }
  }

  account_id   = each.value.name
  display_name = "WIF SA for ${each.value.team} in ${var.env_name}"
}

resource "google_project_iam_member" "sa_roles" {
  for_each = {
    for team_name, config in var.teams :
    for sa in config.gcp_service_accounts :
    for role in sa.roles :
    "${team_name}-${sa.name}-${replace(role, "/", "-")}" => {
      sa_name = sa.name
      team    = team_name
      role    = role
    }
  }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.team_sas["${each.value.team}-${each.value.sa_name}"].email}"
}

resource "google_service_account_iam_member" "wif_binding" {
  for_each = google_service_account.team_sas

  service_account_id = each.value.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${var.project_id}/locations/global/workloadIdentityPools/${var.pool_id}/*"
}

modules/team_sa/variables.tf
variable "project_id" {}
variable "pool_id" {}
variable "provider_id" {}
variable "env_name" {}

variable "teams" {
  description = "Mapping of teams and their service accounts"
  type = map(object({
    gcp_service_accounts = list(object({
      name  = string
      roles = list(string)
    }))
  }))
}

modules/team_sa/outputs.tf
output "service_account_emails" {
  value = {
    for sa_key, sa in google_service_account.team_sas :
    sa_key => sa.email
  }
}