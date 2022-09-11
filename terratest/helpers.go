package test

import (
	"io/ioutil"
	"log"
	"os"
	"sync"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"golang.org/x/crypto/ssh"
)

const (
	LocationEW1 = "west-europe"
	LocationUE2 = "east-us-2"
)

func getFwAddress(fwLocation string) string {
	bytes, err := os.ReadFile("../fw-info-" + fwLocation)
	if err != nil { //TODO: consider implementing reading this from terragrunt. However, reading from TG is very slow and requires t.Testing
		log.Fatal(err)
	}
	return string(bytes)+":22"
}

func getVmAddress(fwLocation string, spoke string, subnet string, index string) string {
	return LocationEW1+"-"+spoke+subnet+index+".azure.lab:22"
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
		log.Fatal(err)
	}
	signer, err := ssh.ParsePrivateKey(key)
	if err != nil {
		log.Fatal(err)
	}

	return ssh.PublicKeys(signer)
}

func _getSshClient(bastionAddr string, vmAddr string) *ssh.Client {
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
	return ssh.NewClient(ncc, chans, reqs)
}

func getSshClient(bastionAddr string, vmAddr string) *ssh.Client {
	sshClients.m.Lock()
	defer sshClients.m.Unlock()
	if sshClients.c == nil {
		sshClients.c = make(map[string]*ssh.Client)
	}
	if val, ok := sshClients.c[bastionAddr+vmAddr]; ok {
		return val
	}
	sshClient := _getSshClient(bastionAddr, vmAddr)
	sshClients.c[bastionAddr+vmAddr] = sshClient
	return sshClient
}

var sshClients struct {
	c map[string]*ssh.Client
	m sync.Mutex
}
