output "service_account_emails" {
  value = {
    for sa_key, sa in google_service_account.team_sas :
    sa_key => sa.email
  }
}