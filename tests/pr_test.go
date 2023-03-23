package test

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"gopkg.in/yaml.v3"
)

const completeExampleTerraformDir = "examples/observability_archive"
const atEventRoutingTerraformDir = "examples/observability_at_event_routing"

const resourceGroup = "geretain-test-observability-instances"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

type Config struct {
	ExistingActivityTrackerCRN    string `yaml:"activityTrackerFrankfurtCrn"`
	ExistingActivityTrackerKey    string `yaml:"activityTrackerFrankfurtResourceKeyName"`
	ExistingActivityTrackerRegion string `yaml:"activityTrackerFrankfurtRegion"`
}

// Temporarly ignore until we bump to v4 of key protect all inclusive
var ignoreDestroys = []string{
	"module.key_protect.module.key_protect[0].restapi_object.enable_metrics[0]",
}

var sharedInfoSvc *cloudinfo.CloudInfoService
var existingActivityTrackerCRN string
var existingActivityTrackerKey string
var existingActivityTrackerRegion string

// TestMain will be run before any parallel tests, used to set up a shared InfoService object to track region usage
// for multiple tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	// Read the YAML file contents
	data, err := os.ReadFile(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}
	// Create a struct to hold the YAML data
	var config Config
	// Unmarshal the YAML data into the struct
	err = yaml.Unmarshal(data, &config)
	if err != nil {
		log.Fatal(err)
	}
	// Parse the existing activity tracker crn from data
	existingActivityTrackerCRN = config.ExistingActivityTrackerCRN
	existingActivityTrackerKey = config.ExistingActivityTrackerKey
	existingActivityTrackerRegion = config.ExistingActivityTrackerRegion

	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		IgnoreDestroys: testhelper.Exemptions{
			List: ignoreDestroys,
		},
		CloudInfoService:              sharedInfoSvc,
		ExcludeActivityTrackerRegions: true,
	})

	return options
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "obs-complete", completeExampleTerraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunEventRoutingExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:                       t,
		TerraformDir:                  atEventRoutingTerraformDir,
		Prefix:                        "obs-at-event-routing",
		ResourceGroup:                 resourceGroup,
		CloudInfoService:              sharedInfoSvc,
		ExcludeActivityTrackerRegions: true,
		TerraformVars: map[string]interface{}{
			"existing_activity_tracker_crn":      existingActivityTrackerCRN,
			"existing_activity_tracker_key_name": existingActivityTrackerKey,
			"existing_activity_tracker_region":   existingActivityTrackerRegion,
		},
	})
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "obs-upg", completeExampleTerraformDir)
	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
