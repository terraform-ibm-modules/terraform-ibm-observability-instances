terraform {
  required_version = ">= 1.0.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.51.0"
    }
    logdna = {
      source  = "logdna/logdna"
      version = "1.14.2"
    }
  }
}
