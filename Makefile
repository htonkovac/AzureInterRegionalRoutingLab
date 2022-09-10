fmt:
	terraform fmt -recursive
	terragrunt hclfmt
	cd terratest && go fmt