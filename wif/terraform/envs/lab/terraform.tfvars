project_id         = "gcp-lab-id"
pool_id            = "wif-lab-pool"
provider_id        = "wif-lab-provider"
openshift_oidc_url = "https://openshift-lab.example.com"
env_name           = "lab"

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