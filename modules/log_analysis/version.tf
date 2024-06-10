terraform {
  required_version = ">= 1.0.0"
  required_providers {
    # Use "greater than or equal to" range in modules
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.56.1, < 2.0.0"
    }
    logdna = {
      source                = "logdna/logdna"
      version               = ">= 1.14.2, < 2.0.0"
      configuration_aliases = [logdna.ld]
    }
  }
}
