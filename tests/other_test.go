package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

const basicExampleTerraformDir = "examples/observability_basic"

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "obs-basic", basicExampleTerraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
