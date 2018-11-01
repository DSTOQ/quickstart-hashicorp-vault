pid_file = "/tmp/vault-agent.pidfile"

exit_after_auth = false # disable if running in background

# vault write -f auth/aws/role/service auth_type=iam  max_ttl=5m bound_iam_principal_arn="arn:aws:iam::486690458968:role/service"
# vault write auth/aws/config/client iam_server_id_header_value=staging-vault
# vault login -method=aws header_value=staging-vault role=service

auto_auth {
  method "aws" {
    mount_path = "auth/aws"

    config = {
      role         = "service"
      type         = "iam"
      header_value = "staging-vault"
    }
  }

  sink "file" {
    config = {
      path = "/shared/token"
    }
  }
}
