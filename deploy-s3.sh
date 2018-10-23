#!/usr/bin/env bash

set -e

aws s3 sync . s3://quickstart-hashicorp-vault \
	--delete \
	--exclude="*" \
	--include="scripts/*" \
	--include="templates/*" \
	--include="submodules/quickstart-aws-vpc/templates/*" \
	--include="submodules/quickstart-hashicorp-consul/templates/*" \
	--include="submodules/quickstart-hashicorp-consul/scripts/*" \
	--include="submodules/quickstart-linux-bastion/templates/*" \
	--include="submodules/quickstart-linux-bastion/scripts/*" 


