provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

resource "azurerm_app_service_plan" "example" {
  name                = "example-app-service-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "Linux"

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "example-app-service"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id
}

resource "azurerm_sql_server" "example" {
  name                         = "example-sql-server"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "Password12345!"  # Replace with a secure password

  tags = {
    environment = "dev"
  }
}

resource "azurerm_sql_database" "example" {
  name                        = "example-sql-db"
  resource_group_name         = azurerm_resource_group.example.name
  location                    = azurerm_resource_group.example.location
  server_name                 = azurerm_sql_server.example.name
  requested_service_objective = "S0"  # Replace with the desired performance tier
}

resource "azurerm_app_service_connection_string" "example" {
  name                = "example-db-connection"
  app_service_id      = azurerm_app_service.example.id
  type                = "SQLServer"
  connection_string   = "Server=tcp:${azurerm_sql_server.example.fqdn},1433;Initial Catalog=${azurerm_sql_database.example.name};User Id=${azurerm_sql_server.example.administrator_login};Password=${azurerm_sql_server.example.administrator_login_password};"
  in_use              = true
}
