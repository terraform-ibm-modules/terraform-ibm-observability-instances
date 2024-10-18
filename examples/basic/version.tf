terraform {
  required_version = ">= 1.0.0"
  required_providers {
    # Ensure that there is always 1 example locked into the lowest provider version of the range defined in the main
    # module's version.tf (basic), and 1 example that will always use the latest provider version (advanced).
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.70.0"
    }
  }
}
