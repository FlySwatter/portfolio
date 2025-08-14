data "google_project" "current" {
  project_id = var.project_id
}

resource "google_service_account" "team_sas" {
  for_each = {
    for team_name, config in var.teams : 
    "${team_name}-${sa.name}" => {
      team = team_name
      name = sa.name
    }
    for sa in config.gcp_service_accounts
  }
  project      = var.project_id
  account_id   = each.value.name
  display_name = "WIF SA for ${each.value.team} in ${var.env_name}"
}

resource "google_service_account_iam_member" "wif_binding" {
  for_each = {
    for team_name, config in var.teams : 
    "${team_name}-${sa.name}-${k8s.namespace}-${k8s.sa_name}" => {
      team    = team_name
      sa_name = sa.name
      ns      = k8s.namespace
      k8s_sa  = k8s.sa_name
    }
    for sa in config.gcp_service_accounts
    for k8s in sa.allowed_k8s
  }
  service_account_id = google_service_account.team_sas["${each.value.team}-${each.value.sa_name}"].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${var.pool_id}/attribute.k8s_ns/${each.value.ns}/attribute.k8s_sa_name/${each.value.k8s_sa}"
}

resource "google_service_account_iam_member" "wif_binding" {
  for_each           = google_service_account.team_sas
  service_account_id = each.value.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${var.pool_id}/*"
}