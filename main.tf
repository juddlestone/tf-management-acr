module "naming" {
  source = "Azure/naming/azurerm"
  suffix = ["management", "acr", local.location_short]
}

resource "azurerm_resource_group" "resource_group" {
  name     = local.resource_group_name
  location = local.location

  tags = local.tags
}

resource "azurerm_container_registry" "container_registry" {
  name                       = local.container_registry_name
  resource_group_name        = azurerm_resource_group.resource_group.name
  location                   = azurerm_resource_group.resource_group.location
  sku                        = "Basic"
  admin_enabled              = false
  network_rule_bypass_option = "AzureServices"

  tags = local.tags
}
