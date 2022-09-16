package test

// https://github.com/golang/go/wiki/TableDrivenTests
// run tests with: APP_SVC_NAME="xx" RG_NAME="xx" go test -v -count=1 .
import (
	"log"
	"os"
	"os/exec"
	"testing"

	"github.com/stretchr/testify/assert"
)

const (
	EnvAppSvcName      = "APP_SVC_NAME"
	EnvRgName          = "RG_NAME"
	EnvArmClientId     = "ARM_CLIENT_ID"
	EnvArmClientSecret = "ARM_CLIENT_SECRET"
	EnvArmTenantId     = "ARM_TENANT_ID"
)

func TestMain(m *testing.M) {
	// In TestMain (which runs before all tests):
	// we make sure to first log out of all accounts (to prevent stray accounts and also to refresh credentials)
	// we make sure we log in with the spn details provided to the tests.
	client_id, ok := os.LookupEnv(EnvArmClientId)
	if !ok {
		log.Fatal(EnvArmClientId + " is required")
	}
	client_secret, ok := os.LookupEnv(EnvArmClientSecret)
	if !ok {
		log.Fatal(EnvArmClientSecret + " is required")
	}
	tenant_id, ok := os.LookupEnv(EnvArmTenantId)
	if !ok {
		log.Fatal(EnvArmTenantId + " is required")
	}

	for _, env := range []string{EnvAppSvcName, EnvRgName} {
		_, ok := os.LookupEnv(env)
		if !ok {
			log.Fatal(env + " is required")
		}
	}

	cmd := exec.Command("/bin/bash", "-c", "az logout")
	_ = cmd.Run() //logout throws errors if there is no account logged in. That is ok.

	cmd = exec.Command("/bin/bash", "-c", "az login --service-principal --username "+client_id+" --password "+client_secret+" --tenant "+tenant_id)
	err := cmd.Run()

	if err != nil {
		if exiterror, ok := err.(*exec.ExitError); ok {
			log.Print(string(exiterror.Stderr))
		} else {
			log.Fatal(err)
		}
	}

	code := m.Run()
	os.Exit(code)
}

func Test_can_run_echo_in_bash(t *testing.T) {
	//tests rely on bash so bash should work

	cmd := exec.Command("/bin/bash", "-c", "echo -n hi")
	stdout, err := cmd.Output()
	assert.NoError(t, err)

	assert.Contains(t, string(stdout), "i")
}

func Test_principal_logged_in(t *testing.T) {
	//verify that user is logged in by listing all rgs
	//assumption: any authenticated user should be able to list it's own groups even if there are none

	cmd := exec.Command("/bin/bash", "-c", "az group list")
	err := cmd.Run()
	// cmd.
	assert.NoError(t, err)
}

func Test_principal_can_NOT_disable_vnet_route_all(t *testing.T) {
	//verify that the principal can not alter the --vnet-route-all-enabled setting. This should return AuthorizationFailed.
	app_svc_name, _ := os.LookupEnv(EnvAppSvcName)
	rg_name, _ := os.LookupEnv(EnvRgName)

	cmd := exec.Command("/bin/bash", "-c", "az webapp config set --vnet-route-all-enabled true --name "+app_svc_name+" --resource-group "+rg_name)
	stdout, err := cmd.Output()
	if err != nil {
		if exiterror, ok := err.(*exec.ExitError); ok {
			assert.Contains(t, string(exiterror.Stderr), "Code: AuthorizationFailed") // should fail with AuthorizationFailed if the user doesn't have the right rbac role
		} else {
			log.Fatal(err)
		}
	}

	assert.NotContains(t, string(stdout), "vnetRouteAllEnabled") //on success az cli will return a json representation of the appservice settings
}
func Test_principal_can_configure_app_settings(t *testing.T) {
	//verify that the principal can set appsettings.
	app_svc_name, _ := os.LookupEnv(EnvAppSvcName)
	rg_name, _ := os.LookupEnv(EnvRgName)
	cmd := exec.Command("/bin/bash", "-c", "az webapp config appsettings set  --settings WEBSITE_RUN_FROM_PACKAGE='1' --name "+app_svc_name+" --resource-group "+rg_name)
	stdout, err := cmd.Output()
	if err != nil {
		if exiterror, ok := err.(*exec.ExitError); ok {
			assert.Contains(t, string(exiterror.Stderr), "Code: AuthorizationFailed")
		} else {
			log.Fatal(err)
		}
	}

	assert.Contains(t, string(stdout), "WEBSITE_RUN_FROM_PACKAGE")
}

//TODO: write tests for slots as well
