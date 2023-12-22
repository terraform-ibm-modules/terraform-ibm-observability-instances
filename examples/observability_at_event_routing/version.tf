terraform {
  required_version = ">= 1.0.0, < 1.6.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.56.1"
    }
    logdna = {
      source  = "logdna/logdna"
      version = "1.14.2"
    }
  }
}
