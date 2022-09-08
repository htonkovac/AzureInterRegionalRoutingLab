package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"os"
)

func TestTerragruntExample(t *testing.T) {

	
	terraformVMOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terragrunt/subscription/us-east-2/vm",
		TerraformBinary: "terragrunt",
	})

	terraformBastionOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terragrunt/subscription/us-east-2/bastion",
		TerraformBinary: "terragrunt",
	})

	privateKey := terraform.Output(t, terraformVMOptions, "private_key")
	vmId := terraform.Output(t, terraformVMOptions, "vm_id")
	bastionName = terraform.Output(t, terraformBastionOptions, "bastion_name")

	RunAz("az network bastion ssh --name MyBastionHost --resource-group MyResourceGroup --target-resource-id vmResourceId --auth-type password --username xyz")
	assert.Equal(t, "one input another input", output)
}


// az network bastion ssh --name MyBastionHost --resource-group MyResourceGroup --target-resource-id vmResourceId --auth-type password --username xyz

func RunAz(cmd string) []byte {
	out, err := exec.Command("bash", "-c", cmd).Output()
	if err != nil {
		panic("some error found")
	}
	return out
}
