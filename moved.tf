# The following moved blocks allow consumers to upgrade from v2 of the module without instances being destroyed
moved {
  from = logdna_archive.logdna_config
  to   = module.logdna.logdna_archive.archive_config
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
  from = ibm_resource_key.log_dna_resource_key
  to   = module.logdna.ibm_resource_key.resource_key
}

moved {
  from = ibm_resource_instance.sysdig
  to   = module.sysdig.ibm_resource_instance.sysdig
}

moved {
  from = ibm_resource_key.sysdig_resource_key
  to   = module.sysdig.ibm_resource_key.resource_key
}

moved {
  from = ibm_resource_instance.activity_tracker
  to   = module.activity_tracker.ibm_resource_instance.activity_tracker
}

moved {
  from = ibm_resource_key.at_resource_key
  to   = module.activity_tracker.ibm_resource_key.resource_key
}
