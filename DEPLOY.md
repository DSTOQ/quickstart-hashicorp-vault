# How to deploy a new stack

1. Generate a EC2 keypair and save private key to `~/.ssh/DSTOQ_KP_1.pem` (it will be used to SSH into vault server via bastion host)

1. Copy template files to S3 bucket and deploy a new stack:
 ```
 ./deploy-s3.sh
 ```
3. Configure ssh and connect
Example SSH config is: `./ssh_config.example.txt`.
It needs to be edited with actual IP addresses and copied to (or merged with the existing one) `~/.ssh/config`
```shell
ssh vault1
```
4. Init vault (on 1 server)
```shell
vault operator init -key-shares=3 -key-threshold=2 # save the output
```

5. Unseal vault (on every server)
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

8. Enable audit logs:
```shell
vault audit enable file file_path=/var/log/vault_audit.logstatus
```

