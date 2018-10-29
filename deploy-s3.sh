#!/usr/bin/env bash

set -e

aws s3 sync . s3://quickstart-hashicorp-vault \
	--delete \
	--acl="public-read" \
	--exclude="*" \
	--include="scripts/*" \
	--include="templates/*" \
	--include="submodules/quickstart-aws-vpc/templates/*" \
	--include="submodules/quickstart-hashicorp-consul/templates/*" \
	--include="submodules/quickstart-hashicorp-consul/scripts/*" \
	--include="submodules/quickstart-linux-bastion/templates/*" \
	--include="submodules/quickstart-linux-bastion/scripts/*"

if [ "$1" == "create" ]; then

    aws cloudformation create-stack \
        --stack-name "Vault-Staging" \
	--template-url "http://quickstart-hashicorp-vault.s3.amazonaws.com/templates/quickstart-hashicorp-vault-master.template" \
	--parameters "ParameterKey=KeyPairName,ParameterValue=DSTOQ_KP_1" \
	             "ParameterKey=VaultAccessCIDR,ParameterValue=10.0.0.0/16" \
	--timeout-in-minutes 30 \
	--capabilities CAPABILITY_IAM \

elif [ "$1" == "update" ]; then

    aws cloudformation update-stack \
        --stack-name "Vault-Staging" \
	--template-url "http://quickstart-hashicorp-vault.s3.amazonaws.com/templates/quickstart-hashicorp-vault-master.template" \
	--parameters "ParameterKey=KeyPairName,ParameterValue=DSTOQ_KP_1" \
	             "ParameterKey=VaultAccessCIDR,ParameterValue=10.0.0.0/16" \
	--capabilities CAPABILITY_IAM \

fi
