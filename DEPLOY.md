# How to deploy a new stack

1. Copy template files to S3 bucket
 ```
 ./deploy-s3.sh
 ```

2. [Open Cloud Formation console](https://eu-central-1.console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks?filter=active)
1. Click "Create Stack" button
1. Specify an Amazon S3 template URL: 
```
http://quickstart-hashicorp-vault.s3.eu-central-1.amazonaws.com/templates/quickstart-hashicorp-vault-master.template
```
2. Specify a stack name, e.g. `DSTOQ-Vault`
