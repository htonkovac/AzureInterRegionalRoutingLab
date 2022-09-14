SHELL=/bin/bash
#interestingly sh and bash have different implementations of the echo command. Therefore using bash.

FW_EW1_IP_FROM_TF=$(shell cd terragrunt/subscription/eu-west-1/hub-and-spoke && terragrunt output -raw fw_public_ip_address 2>/dev/null)
FW_UE2_IP_FROM_TF=$(shell cd terragrunt/subscription/us-east-2/hub-and-spoke && terragrunt output -raw fw_public_ip_address 2>/dev/null)

FW_EW1_IP=$(shell cat fw-info-west-europe)
FW_UE2_IP=$(shell cat fw-info-us-east-2)

fmt:
	terraform fmt -recursive
	terragrunt hclfmt
	cd terratest && go fmt

tg_apply_all:
	cd terragrunt/subscription && terragrunt run-all apply --terragrunt-non-interactive

tg_destroy_all:
	cd terragrunt/subscription && terragrunt run-all destroy --terragrunt-non-interactive

#Faster and easier than terragrunt
manual_destory_all:
	rm fw-info-west-europe
	rm fw-info-us-east-2
	az monitor diagnostic-settings delete --name diag_settings --resource /subscriptions/8c581abc-4029-48af-ad32-5eabd64a4fe9/resourceGroups/AzureInterRegionalRoutingLab/providers/Microsoft.Network/azureFirewalls/azfw-west-europe
	az monitor diagnostic-settings delete --name diag_settings --resource /subscriptions/8c581abc-4029-48af-ad32-5eabd64a4fe9/resourceGroups/AzureInterRegionalRoutingLab/providers/Microsoft.Network/azureFirewalls/azfw-east-us-2
	az group delete -n AzureInterRegionalRoutingLab -y --no-wait


tg_apply_vms:
	cd terragrunt/subscription/eu-west-1/vm && terragrunt run-all apply --terragrunt-non-interactive
	cd terragrunt/subscription/us-east-2/vm && terragrunt run-all apply --terragrunt-non-interactive
tg_destroy_vms:
	cd terragrunt/subscription/eu-west-1/vm && terragrunt run-all destroy --terragrunt-non-interactive
	cd terragrunt/subscription/us-east-2/vm && terragrunt run-all destroy --terragrunt-non-interactive

tg_apply_app_svc:
	cd terragrunt/subscription/eu-west-1/app-svcs && terragrunt run-all apply --terragrunt-non-interactive
	cd terragrunt/subscription/us-east-2/app-svcs && terragrunt run-all apply --terragrunt-non-interactive
tg_destroy_app_svc:
	cd terragrunt/subscription/eu-west-1/app-svcs && terragrunt run-all destroy --terragrunt-non-interactive
	cd terragrunt/subscription/us-east-2/app-svcs && terragrunt run-all destroy --terragrunt-non-interactive

tg_apply_appgw:
	cd terragrunt/subscription/eu-west-1/appgateway && terragrunt run-all apply --terragrunt-non-interactive

tg_destroy_us_east:
	cd terragrunt/subscription/us-east-2 && terragrunt run-all destroy --terragrunt-non-interactive


tg_apply_kvs:
	cd terragrunt/subscription/eu-west-1/kv && terragrunt run-all apply --terragrunt-non-interactive
	cd terragrunt/subscription/us-east-2/kv && terragrunt run-all apply --terragrunt-non-interactive
tg_destroy_kvs:
	cd terragrunt/subscription/eu-west-1/kv && terragrunt run-all destroy --terragrunt-non-interactive
	cd terragrunt/subscription/us-east-2/kv && terragrunt run-all destroy --terragrunt-non-interactive

tg_apply_network:
	cd terragrunt/subscription/eu-west-1/hub-and-spoke && terragrunt run-all apply --terragrunt-non-interactive
	cd terragrunt/subscription/us-east-2/hub-and-spoke && terragrunt run-all apply --terragrunt-non-interactive

tg_apply_dns:
	cd terragrunt/subscription/global/dns && terragrunt run-all apply --terragrunt-non-interactive

go_test:
	cd terratest && go test -v

add_ssh_key:
	eval "$(ssh-agent)"
	ssh-add ssh-keys/mykey

# if the repo is cloned there will be no ssh key. This command can generate the key
generate_new_ssh_key:
	ssh-keygen -t rsa -b 4096 -f ./ssh-keys/mykey

# In case we redeploy something the ssh known hosts might need updating
ssh_new_fingerprint:
	ssh-keygen -R $(FW_EW1_IP)

ssh_jumphost:
	ssh -v -A -i ssh-keys/mykey adminuser@$(FW_EW1_IP)

ssh_vm_aa1:
	ssh -v -o StrictHostKeyChecking=no -i ssh-keys/mykey -A -J adminuser@$(FW_EW1_IP) adminuser@west-europe-aa1.azure.lab

ssh_vm_ba1:
	ssh -v -o StrictHostKeyChecking=no -i ssh-keys/mykey -A -J adminuser@$(FW_EW1_IP) adminuser@west-europe-ba1.azure.lab

#fetching fw ips from tf output is slow. This lets us cache the ip's in a temporary file to use for other commands
generate_fw_info:
	echo -n "$(FW_EW1_IP_FROM_TF)" > fw-info-west-europe
	echo -n "$(FW_UE2_IP_FROM_TF)" > fw-info-us-east-2
