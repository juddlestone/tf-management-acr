module "naming" {
  source = "Azure/naming/azurerm"
  suffix = ["man", "acr"]
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

resource "azurerm_container_registry_scope_map" "registry_scope_map" {
  for_each                = local.applications
  name                    = "${each.key}-scope-map"
  container_registry_name = azurerm_container_registry.container_registry.name
  resource_group_name     = azurerm_resource_group.resource_group.name
  actions                 = each.value.action
}

resource "azurerm_container_registry_token" "registry_token" {
  for_each                = local.applications
  name                    = "token-${each.key}"
  container_registry_name = azurerm_container_registry.container_registry.name
  resource_group_name     = azurerm_resource_group.resource_group.name
  scope_map_id            = azurerm_container_registry_scope_map.registry_scope_map[each.key].id
}
