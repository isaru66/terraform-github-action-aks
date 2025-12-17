resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.resource_suffix}"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.main.name
}