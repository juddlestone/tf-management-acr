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
  actions                 = each.value.actions
}

resource "azurerm_container_registry_token" "registry_token" {
  for_each                = local.applications
  name                    = "token-${each.key}"
  container_registry_name = azurerm_container_registry.container_registry.name
  resource_group_name     = azurerm_resource_group.resource_group.name
  scope_map_id            = azurerm_container_registry_scope_map.registry_scope_map[each.key].id
}

resource "time_static" "time_static" {
  for_each = local.applications
}

resource "azurerm_container_registry_token_password" "registry_token_password" {
  for_each                    = local.applications
  container_registry_token_id = azurerm_container_registry_token.registry_token[each.key].id

  password1 {
    expiry = timeadd(time_static.time_static[each.key].rfc3339, "8760h") # 1 year
  }

  password2 {
    expiry = timeadd(time_static.time_static[each.key].rfc3339, "8760h") # 1 year
  }
}
