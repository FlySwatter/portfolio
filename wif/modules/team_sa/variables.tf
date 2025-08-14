variable "project_id" {}
variable "pool_id" {}
variable "env_name" {}
variable "teams" {
  type = map(object({
    gcp_service_accounts = list(object({
      name = string
      roles = list(string)
      allowed_k8s = list(object({  #Restrict to specific OpenShift ns/sa
        namespace = string
        sa_name   = string
      }))
    }))
  }))
}