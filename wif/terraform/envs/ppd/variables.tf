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