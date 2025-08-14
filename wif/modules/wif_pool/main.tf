resource "google_iam_workload_identity_pool" "wif_pool" {
  project                    = var.project_id
  workload_identity_pool_id  = var.pool_id
  display_name               = "WIF Pool for ${var.pool_id}"
}

resource "google_iam_workload_identity_pool_provider" "oidc_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.wif_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "OIDC Provider for OpenShift"
  oidc {
    issuer_uri = var.openshift_oidc_url
  }
  attribute_mapping = {
    "google.subject"          = "assertion.sub"
    "attribute.k8s_ns"        = "assertion['kubernetes.io']['namespace']"
    "attribute.k8s_sa_name"   = "assertion['kubernetes.io']['serviceaccount']['name']"
  }
}