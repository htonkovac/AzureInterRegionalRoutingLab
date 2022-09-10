package test

import (
	"io/ioutil"
	"log"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	// "github.com/stretchr/testify/assert"
	"golang.org/x/crypto/ssh"
)

func TestMain(m *testing.M) {
	exitVal := m.Run()
	os.Exit(exitVal)
}
func TestTerragruntExample(t *testing.T) {

	tfVmOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    "../terragrunt/subscription/eu-west-1/vm/vm-spokeA",
		TerraformBinary: "terragrunt",
	})

	tfAzFwOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    "../terragrunt/subscription/eu-west-1/hub-and-spoke",
		TerraformBinary: "terragrunt",
	})

	vmAddr := terraform.Output(t, tfVmOptions, "private_ip") + ":22"
	bastionAddr := terraform.Output(t, tfAzFwOptions, "fw_public_ip_address") + ":22"

	config := &ssh.ClientConfig{
		User: "adminuser",
		Auth: []ssh.AuthMethod{
			publicKey("../ssh-keys/mykey"),
		},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}
	// connect to the bastion host
	bClient, err := ssh.Dial("tcp", bastionAddr, config)
	if err != nil {
		log.Fatal(err)
	}

	// Dial a connection to the service host, from the bastion
	conn, err := bClient.Dial("tcp", vmAddr)
	if err != nil {
		log.Fatal(err)
	}

	ncc, chans, reqs, err := ssh.NewClientConn(conn, vmAddr, config)
	if err != nil {
		log.Fatal(err)
	}

	// sClient is an ssh client connected to the service host, through the bastion host.
	sClient := ssh.NewClient(ncc, chans, reqs)

	session, err := sClient.NewSession()
	if err != nil {
		log.Fatal(err)
	}

	err = session.Run("echo hi")
	if err != nil {
		log.Fatal(err)
	}
}

func publicKey(path string) ssh.AuthMethod {
	key, err := ioutil.ReadFile(path)
	if err != nil {
		panic(err)
	}
	signer, err := ssh.ParsePrivateKey(key)
	if err != nil {
		panic(err)
	}

	return ssh.PublicKeys(signer)
}
