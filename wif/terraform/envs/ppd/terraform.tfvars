project_id         = "gcp-ppd-id"
pool_id            = "wif-ppd-pool"
provider_id        = "wif-ppd-provider"
openshift_oidc_url = "https://openshift-ppd.example.com"
env_name           = "ppd"

teams = {
  team-a = {
    gcp_service_accounts = [
      {
        name = "team-a-storage"
        roles = ["roles/storage.objectViewer"]
        allowed_k8s = [
          { namespace = "team-a-ns", sa_name = "team-a-sa" }
        ]
      }
    ]
  }
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