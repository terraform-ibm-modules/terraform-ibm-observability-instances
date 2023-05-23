# The following moved blocks allow consumers to upgrade from v2 of the module without instances being destroyed
moved {
  from = logdna_archive.logdna_config
  to   = module.log_analysis.logdna_archive.archive_config
}

moved {
  from = logdna_archive.activity_tracker_config
  to   = module.activity_tracker.logdna_archive.archive_config
}

moved {
  from = ibm_resource_instance.logdna
  to   = module.logdna.ibm_resource_instance.logdna
}

moved {
  from = module.logdna.ibm_resource_instance.logdna
  to = module.log_analysis.ibm_resource_instance.log_analysis
}

moved {
  from = ibm_resource_key.log_dna_resource_key
  to   = module.logdna.ibm_resource_key.resource_key
}

moved {
  from = module.logdna.ibm_resource_key.resource_key
  to = module.log_analysis.ibm_resource_key.resource_key
}

moved {
  from = ibm_resource_instance.sysdig
  to   = module.cloud_monitoring.ibm_resource_instance.cloud_monitoring
}

moved {
  from = ibm_resource_key.sysdig_resource_key
  to   = module.cloud_monitoring.ibm_resource_key.resource_key
}

moved {
  from = ibm_resource_instance.activity_tracker
  to   = module.activity_tracker.ibm_resource_instance.activity_tracker
}

moved {
  from = ibm_resource_key.at_resource_key
  to   = module.activity_tracker.ibm_resource_key.resource_key
}
