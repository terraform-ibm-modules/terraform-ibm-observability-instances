terraform {
  required_version = ">= 1.0.0"
  required_providers {
    # Use "greater than or equal to" range in modules
    logdna = {
      source                = "logdna/logdna"
      version               = ">= 1.14.2"
      configuration_aliases = [logdna.at, logdna.ld]
    }
  }
}
