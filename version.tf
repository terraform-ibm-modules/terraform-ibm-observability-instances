terraform {
  required_version = ">= 1.0.0"
  required_providers {
    # Use "greater than or equal to" range in modules
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.49.0"
    }
    logdna = {
      source                = "logdna/logdna"
      version               = ">= 1.13.1"
      configuration_aliases = [logdna.at, logdna.ld]
    }
  }
}
