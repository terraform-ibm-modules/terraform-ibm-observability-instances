package test

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const defaultExampleTerraformDir = "examples/observability_default"
const resourceGroup = "geretain-test-observability-instances"

var sharedInfoSvc *cloudinfo.CloudInfoService

// TestMain will be run before any parallel tests, used to set up a shared InfoService object to track region usage
// for multiple tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	os.Exit(m.Run())
}

func TestRunDefaultExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:                       t,
		TerraformDir:                  defaultExampleTerraformDir,
		Prefix:                        "obs-all",
		ResourceGroup:                 resourceGroup,
		CloudInfoService:              sharedInfoSvc,
		ExcludeActivityTrackerRegions: true,
		TerraformVars: map[string]interface{}{
			"logdna_plan":           "7-day",
			"sysdig_plan":           "graduated-tier",
			"activity_tracker_plan": "7-day",
		},
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	// TODO: Remove this line after the first merge to primary branch is complete to enable upgrade test
	t.Skip("Skipping upgrade test until initial code is in primary branch")
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:                       t,
		TerraformDir:                  defaultExampleTerraformDir,
		Prefix:                        "obs-upg",
		ResourceGroup:                 resourceGroup,
		CloudInfoService:              sharedInfoSvc,
		ExcludeActivityTrackerRegions: true,
		TerraformVars: map[string]interface{}{
			"logdna_plan":           "7-day",
			"sysdig_plan":           "graduated-tier",
			"activity_tracker_plan": "7-day",
		},
	})

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
