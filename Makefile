FW_IP=$(shell cd terragrunt/subscription/eu-west-1/hub-and-spoke && terragrunt output -raw fw_public_ip_address 2>/dev/null)
fmt:
	terraform fmt -recursive
	terragrunt hclfmt
	cd terratest && go fmt
tg_apply_all:
	cd terragrunt/subscription && terragrunt run-all apply --terragrunt-non-interactive
go_test:
	cd terratest && go test -v
add_ssh_key:
	eval "$(ssh-agent)"
	ssh-add ssh-keys/mykey

jumphost:
	ssh -i ssh-keys/mykey -A -J adminuser@$(FW_IP) adminuser@10.1.1.4