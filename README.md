# Vault on the AWS Cloud

VAULT_VERSION 0.10.4
CONSUL_VERSION '1.2.2'
CONSUL_TEMPLATE_VERSION='0.19.5'

### Deployment options:
* Deployment of HashiCorp Vault into a new VPC (end-to-end deployment) builds a new VPC with public and private subnets, and then deploys HashiCorp Vault into that infrastructure.
* Deployment of HashiCorp Vault into an existing VPC provisions HashiCorp Vault into your existing infrastructure. 

### Architecture
![quickstart-hashicorp-consul](/images/vault.png)

## How to deploy a new stack

1. Generate a EC2 keypair and save private key to `~/.ssh/DSTOQ_KP_1.pem` (it will be used to SSH into vault server via bastion host)

1. Copy template files to S3 bucket and initiate a deployment of a new stack:
 ```
 ./deploy-s3.sh
 ```
3. Configure ssh and connect

[Example SSH config](ssh_config.example.txt) needs to be edited with actual IP addresses of EC2 instances and copied to (or merged with the existing one) in your home folder (`~/.ssh/config`)
```shell
ssh vault1
```
4. Init vault (on one server only)
```shell
vault operator init -key-shares=3 -key-threshold=2 
```
**Don't forget ot securely save the output with unseal keys and root token!**

5. Unseal vault (on every vault server)
```shell
vault operator unseal # <- unseal key 1
vault operator unseal # <- unseal key 2
```

6. Login
```shell
vault login token=<root-token>
```

7. Enable transit
```shell
vault secrets enable transit 
```

8. Enable AWS Auth backend
```shell
vault auth enable aws
```

9. Enable audit logs:
```shell
vault audit enable file file_path=/var/log/vault_audit.logstatus
```

## How to backup vault state

*Even though vault state is encrypted at rest, it still needs to be kept securely.*

As vault uses Consul cluster as a storage backend, one could use [consul snapshot](https://www.consul.io/docs/commands/snapshot.html) to backup/restore vault state.

Other alternative is to use a [vault operator migrate](https://www.vaultproject.io/docs/commands/operator/migrate.html) command to copy vault state from consul to the file backend. [Config file](migrate.hcl) for such migration needs to be copied on one of the vault servers, 
```
scp migrate.hcl vault1:~
``` 
 and could be used like this:

```shell
➤ scp migrate.hcl vault1:~
migrate.hcl  
➤ ssh vault1 "vault operator migrate -config migrate.hcl"
2018-10-26T08:15:28.403Z [INFO]  copied key: path=audit/e574101e-211f-65c6-e95a-b505d10b75c6/salt
2018-10-26T08:15:28.406Z [INFO]  copied key: path=core/audit
2018-10-26T08:15:28.408Z [INFO]  copied key: path=core/auth
2018-10-26T08:15:28.412Z [INFO]  copied key: path=core/cluster/local/info
2018-10-26T08:15:28.414Z [INFO]  copied key: path=core/keyring
2018-10-26T08:15:28.417Z [INFO]  copied key: path=core/leader/691dd5e7-a56a-f54b-56db-058fdbb91b36
2018-10-26T08:15:28.419Z [INFO]  copied key: path=core/local-audit
2018-10-26T08:15:28.420Z [INFO]  copied key: path=core/local-auth
2018-10-26T08:15:28.422Z [INFO]  copied key: path=core/local-mounts
2018-10-26T08:15:28.423Z [INFO]  copied key: path=core/master
2018-10-26T08:15:28.425Z [INFO]  copied key: path=core/mounts
2018-10-26T08:15:28.426Z [INFO]  copied key: path=core/seal-config
2018-10-26T08:15:28.429Z [INFO]  copied key: path=core/wrapping/jwtkey
2018-10-26T08:15:28.434Z [INFO]  copied key: path=logical/8d3a08c6-01a2-5bc4-c9d3-8cad51e93807/archive/my-key
2018-10-26T08:15:28.437Z [INFO]  copied key: path=logical/8d3a08c6-01a2-5bc4-c9d3-8cad51e93807/policy/my-key
2018-10-26T08:15:28.441Z [INFO]  copied key: path=sys/policy/control-group
2018-10-26T08:15:28.443Z [INFO]  copied key: path=sys/policy/default
2018-10-26T08:15:28.447Z [INFO]  copied key: path=sys/policy/response-wrapping
2018-10-26T08:15:28.450Z [INFO]  copied key: path=sys/token/accessor/6698e41a7e1f3a0dd1e7d0a2e34f17c7f1950d45
2018-10-26T08:15:28.453Z [INFO]  copied key: path=sys/token/id/da8b16895cef8d3312bd528973ec7d5fa007635d
2018-10-26T08:15:28.454Z [INFO]  copied key: path=sys/token/salt
Success! All of the keys have been migrated.
➤ scp -qr vault1:~/vault_backup .
➤ ssh vault1 "rm -rf vault_backup"
```

This vault state copied locally could be used to start local vault with the following config.hcl:
```hcl
storage "file" {
  path = "./vault_backup/"
}

disable_mlock = true

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = 1
}

```

Local vault then needs to be unsealed with the same seal keys used for the cloud vault.