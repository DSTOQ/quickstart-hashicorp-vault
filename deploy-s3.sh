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

STACK="Vault-Stg"
CONSUL="$STACK-Consul"
PRIVATE_SN_1="subnet-05d668fb0715fd704"
PRIVATE_SN_2="subnet-0ddbcdcfeec78b6f6"
PRIVATE_SN_3="subnet-078c83c9cd2ccee1a"
BASTION_SG="sg-0765d27c9924c83e5"

if [ "$1" == "bastion" ]; then

	aws cloudformation create-stack \
		--stack-name "Bastion" \
		--timeout-in-minutes 30 \
		--template-url "http://quickstart-hashicorp-vault.s3.amazonaws.com/submodules/quickstart-linux-bastion/templates/linux-bastion.template" \
		--capabilities CAPABILITY_IAM \
		--disable-rollback \
		--parameters "ParameterKey=VPCID,ParameterValue=vpc-04d704823863b9c19" \
					 "ParameterKey=RemoteAccessCIDR,ParameterValue=0.0.0.0/0" \
		             "ParameterKey=KeyPairName,ParameterValue=DSTOQ_KP_1" \
		             "ParameterKey=EnableTCPForwarding,ParameterValue=true" \
					 "ParameterKey=PublicSubnet1ID,ParameterValue=subnet-0b036bba4816576af" \
					 "ParameterKey=PublicSubnet2ID,ParameterValue=subnet-000168c4cd22e0240" \
					 "ParameterKey=PublicSubnet2ID,ParameterValue=subnet-01f48a611ef62b579" \

elif [ "$1" == "consul" ]; then
    aws cloudformation create-stack \
        --stack-name $CONSUL \
		--timeout-in-minutes 30 \
		--template-url "http://quickstart-hashicorp-vault.s3.amazonaws.com/submodules/quickstart-hashicorp-consul/templates/quickstart-hashicorp-consul.template" \
		--capabilities CAPABILITY_IAM \
		--parameters "ParameterKey=VPCID,ParameterValue=vpc-04d704823863b9c19" \
                     "ParameterKey=VPCCIDR,ParameterValue=10.0.0.0/16" \
		             "ParameterKey=KeyPair,ParameterValue=DSTOQ_KP_1" \
					 "ParameterKey=PrivateSubnet1ID,ParameterValue=$PRIVATE_SN_1" \
					 "ParameterKey=PrivateSubnet2ID,ParameterValue=$PRIVATE_SN_2" \
					 "ParameterKey=PrivateSubnet3ID,ParameterValue=$PRIVATE_SN_3" \
					 "ParameterKey=BastionSecurityGroupID,ParameterValue=$BASTION_SG" \

elif [ "$1" == "consul-update" ]; then
    aws cloudformation update-stack \
        --stack-name $CONSUL \
		--template-url "http://quickstart-hashicorp-vault.s3.amazonaws.com/submodules/quickstart-hashicorp-consul/templates/quickstart-hashicorp-consul.template" \
		--capabilities CAPABILITY_IAM \
		--parameters "ParameterKey=VPCID,ParameterValue=vpc-04d704823863b9c19" \
                     "ParameterKey=VPCCIDR,ParameterValue=10.0.0.0/16" \
		             "ParameterKey=KeyPair,ParameterValue=DSTOQ_KP_1" \
					 "ParameterKey=PrivateSubnet1ID,ParameterValue=$PRIVATE_SN_1" \
					 "ParameterKey=PrivateSubnet2ID,ParameterValue=$PRIVATE_SN_2" \
					 "ParameterKey=PrivateSubnet3ID,ParameterValue=$PRIVATE_SN_3" \
					 "ParameterKey=BastionSecurityGroupID,ParameterValue=$BASTION_SG" \

elif [ "$1" == "vault" ]; then

    aws cloudformation create-stack \
        --stack-name $STACK \
		--timeout-in-minutes 30 \
		--template-url "http://quickstart-hashicorp-vault.s3.amazonaws.com/templates/quickstart-hashicorp-vault.template" \
		--capabilities CAPABILITY_IAM \
		--parameters "ParameterKey=VPCID,ParameterValue=vpc-04d704823863b9c19" \
                     "ParameterKey=VPCCIDR,ParameterValue=10.0.0.0/16" \
					 "ParameterKey=VaultAccessCIDR,ParameterValue=10.0.0.0/16" \
					 "ParameterKey=AccessCIDR,ParameterValue=0.0.0.0/0" \
		             "ParameterKey=KeyPair,ParameterValue=DSTOQ_KP_1" \
					 "ParameterKey=PrivateSubnet1ID,ParameterValue=$PRIVATE_SN_1" \
					 "ParameterKey=PrivateSubnet2ID,ParameterValue=$PRIVATE_SN_2" \
					 "ParameterKey=BastionSecurityGroupID,ParameterValue=$BASTION_SG" \
					 "ParameterKey=ConsulEc2RetryTagKey,ParameterValue=aws:cloudformation:stack-name" \
					 "ParameterKey=ConsulEc2RetryTagValue,ParameterValue=$CONSUL" \

elif [ "$1" == "vault-update" ]; then

    aws cloudformation update-stack \
        --stack-name $STACK \
		--template-url "http://quickstart-hashicorp-vault.s3.amazonaws.com/templates/quickstart-hashicorp-vault.template" \
		--capabilities CAPABILITY_IAM \
		--parameters "ParameterKey=VPCID,ParameterValue=vpc-04d704823863b9c19" \
                     "ParameterKey=VPCCIDR,ParameterValue=10.0.0.0/16" \
					 "ParameterKey=VaultAccessCIDR,ParameterValue=10.0.0.0/16" \
					 "ParameterKey=AccessCIDR,ParameterValue=0.0.0.0/0" \
		             "ParameterKey=KeyPair,ParameterValue=DSTOQ_KP_1" \
					 "ParameterKey=PrivateSubnet1ID,ParameterValue=$PRIVATE_SN_1" \
					 "ParameterKey=PrivateSubnet2ID,ParameterValue=$PRIVATE_SN_2" \
					 "ParameterKey=BastionSecurityGroupID,ParameterValue=$BASTION_SG" \
					 "ParameterKey=ConsulEc2RetryTagKey,ParameterValue=aws:cloudformation:stack-name" \
					 "ParameterKey=ConsulEc2RetryTagValue,ParameterValue=$CONSUL" \

elif [ "$1" == "update" ]; then

    aws cloudformation update-stack \
        --stack-name $STACK \
	--template-url "http://quickstart-hashicorp-vault.s3.amazonaws.com/templates/quickstart-hashicorp-vault-master.template" \
	--parameters "ParameterKey=KeyPairName,ParameterValue=DSTOQ_KP_1" \
	             "ParameterKey=VaultAccessCIDR,ParameterValue=10.0.0.0/16" \
	--capabilities CAPABILITY_IAM \

fi
