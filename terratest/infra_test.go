package test

import (
	"os"
	"os/exec"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	// "os"
)

func TestMain(m *testing.M) {
	// az network bastion tunnel --name MyBastionHost --resource-group MyResourceGroup --target-resource-id vmResourceId --resource-port 22 --port 50022

	exitVal := m.Run()
	os.Exit(exitVal)
}
func TestTerragruntExample(t *testing.T) {

	terraformVMOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    "../terragrunt/subscription/us-east-2/vm-spokeA",
		TerraformBinary: "terragrunt",
	})

	terraformBastionOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    "../terragrunt/subscription/us-east-2/bastion",
		TerraformBinary: "terragrunt",
	})

	vmId := terraform.Output(t, terraformVMOptions, "vm_id")
	bastionName := terraform.Output(t, terraformBastionOptions, "bastion_name")
	resourceGroupName := terraform.Output(t, terraformBastionOptions, "resource_group_name")

	// RunAz("az network bastion ssh --name " + bastionName + " --resource-group" + resourceGroupName + " --target-resource-id "+vmId+" --auth-type ssh-key --username xyz")
	assert.Equal(t, "one input another input", "az network bastion ssh --name "+bastionName+" --resource-group "+resourceGroupName+" --target-resource-id "+vmId+" --auth-type ssh-key --username xyz")
}

// az network bastion ssh --name MyBastionHost --resource-group MyResourceGroup --target-resource-id vmResourceId --auth-type password --username xyz

func RunAz(cmd string) []byte {
	out, err := exec.Command("bash", "-c", cmd).Output()
	if err != nil {
		panic("some error found")
	}
	return out
}
