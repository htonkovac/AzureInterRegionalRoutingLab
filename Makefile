FW_IP=$(shell cd terragrunt/subscription/eu-west-1/hub-and-spoke && terragrunt output -raw fw_public_ip_address 2>/dev/null)
fmt:
	terraform fmt -recursive
	terragrunt hclfmt
	cd terratest && go fmt

tg_apply_all:
	cd terragrunt/subscription && terragrunt run-all apply --terragrunt-non-interactive


tg_apply_vms:
	cd terragrunt/subscription/eu-west-1/vm && terragrunt run-all apply --terragrunt-non-interactive
	cd terragrunt/subscription/us-east-2/vm && terragrunt run-all apply --terragrunt-non-interactive
tg_destroy_vms:
	cd terragrunt/subscription/eu-west-1/vm && terragrunt run-all destroy --terragrunt-non-interactive
	cd terragrunt/subscription/us-east-2/vm && terragrunt run-all destroy --terragrunt-non-interactive

tg_apply_kvs:
	cd terragrunt/subscription/eu-west-1/kv && terragrunt run-all apply --terragrunt-non-interactive
	cd terragrunt/subscription/us-east-2/kv && terragrunt run-all apply --terragrunt-non-interactive
tg_destroy_kvs:
	cd terragrunt/subscription/eu-west-1/kv && terragrunt run-all destroy --terragrunt-non-interactive
	cd terragrunt/subscription/us-east-2/kv && terragrunt run-all destroy --terragrunt-non-interactive

go_test:
	cd terratest && go test -v

add_ssh_key:
	eval "$(ssh-agent)"
	ssh-add ssh-keys/mykey

# In case we redeploy something the ssh known hosts might need updating
ssh_new_fingerprint:
	ssh-keygen -R $(FW_IP)

ssh_jumphost:
	ssh -v -A -i ssh-keys/mykey adminuser@$(FW_IP)

ssh_vm:
	ssh -v  -o StrictHostKeyChecking=no -i ssh-keys/mykey -A -J adminuser@$(FW_IP) adminuser@10.1.1.4
