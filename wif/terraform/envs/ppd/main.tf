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