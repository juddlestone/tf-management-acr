locals {
  location       = "uksouth"
  location_short = substr(local.location, 0, 3)

  resource_group_name     = module.naming.resource_group.name
  container_registry_name = module.naming.container_registry.name

  tags = {
    Criticality  = "Low"
    Environment  = "PRD"
    ServiceOwner = "jack@itsjack.cloud"
    ServiceName  = "ACR"
  }
}

# Applications and their actions
locals {
  applications = {
    "accelerator" = {
      actions = [
        "repositories/accelerator/content/read",
        "repositories/accelerator/content/write"
      ]
    }
  }
}
