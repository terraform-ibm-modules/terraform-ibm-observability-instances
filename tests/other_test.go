package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

const basicExampleTerraformDir = "examples/observability_basic"
const observabilityArchiveTerraformDir = "examples/observability_archive"

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "obs-basic", basicExampleTerraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunEventRoutingExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:                       t,
		TerraformDir:                  observabilityArchiveTerraformDir,
		Prefix:                        "obs-at-event-routing",
		ResourceGroup:                 resourceGroup,
		CloudInfoService:              sharedInfoSvc,
		ExcludeActivityTrackerRegions: true,
		TerraformVars: map[string]interface{}{
			"existing_activity_tracker_crn":      permanentResources["activityTrackerFrankfurtCrn"],
			"existing_activity_tracker_key_name": permanentResources["activityTrackerFrankfurtResourceKeyName"],
			"existing_activity_tracker_region":   permanentResources["activityTrackerFrankfurtRegion"],
			"access_tags":                        permanentResources["accessTags"],
		},
	})
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
