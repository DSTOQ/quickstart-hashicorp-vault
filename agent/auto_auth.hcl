pid_file = "./pidfile"

exit_after_auth = true # disable if running in background

# vault write -f auth/aws/role/terraform auth_type=iam  max_ttl=5m bound_iam_principal_arn="arn:aws:iam::486690458968:role/terraform"
# vault write auth/aws/config/client iam_server_id_header_value=staging-vault
# vault login -method=aws header_value=staging-vault role=terraform

auto_auth {
    method "aws" {
        mount_path = "auth/aws"
        config = { 
                role = "service", 
                type = "iam",
                header_value = "staging-vault" 
        }
    }
    
    sink "file" {
        wrap_ttl = "15m" 
        config = { path = "./token" }
    }
}
