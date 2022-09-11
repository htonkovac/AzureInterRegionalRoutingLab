package test

import (
	"log"
	"testing"

	"github.com/stretchr/testify/assert"
)

func Test_it_is_possible_to_establish_a_ssh_connection_to_a_vm_in_eu_west_through_the_jumphost(t *testing.T) {
	t.Parallel()

	fwEw1 := getFwAddress(LocationEW1)
	vmAddress := getVmAddress(LocationEW1, "a","a","1")

	c := getSshClient(fwEw1, vmAddress)

	session, err := c.NewSession() //TODO: inspect how terratest is implemented to hide error handling
	defer session.Close()
	if err != nil {
		log.Fatal(err)
	}

	bytes,err := session.CombinedOutput("echo -n conn successful!")
	if err != nil {
		log.Fatal(err)
	}
	assert.Equal(t, string(bytes), "conn successful!", "A connection should be established and stdout+err should match the echoed string")
}

func Test_a_vm_in_spoke_A_can_connect_to_a_vm_in_spoke_B_within_eu_west_region(t *testing.T) {
	t.Parallel()

	fwEw1 := getFwAddress(LocationEW1)
	vmAddress := getVmAddress(LocationEW1, "a","a","1")

	c := getSshClient(fwEw1, vmAddress)

	session, err := c.NewSession()
	defer session.Close()
	if err != nil {
		log.Fatal(err)
	}

	bytes,err := session.CombinedOutput("curl ")
	if err != nil {
		log.Fatal(err)
	}
	assert.Equal(t, string(bytes), "conn successful!", "A connection should be established and stdout+err should match the echoed string")

}

func Test_a_vm_in_spoke_A_can_connect_to_a_vm_in_spoke_B_within_same_region(t *testing.T) {
	t.Parallel()
}

func Test_a_vm_in_spoke_A_can_connect_to_a_vm_in_spoke_A_across_regions(t *testing.T) {
	t.Parallel()
}

func Test_a_vm_in_spoke_A_can_NOT_connect_to_a_vm_in_spoke_B_across_regions(t *testing.T) {
	t.Parallel()
}

