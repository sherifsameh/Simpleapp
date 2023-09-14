provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "my-resource-group"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "${var.aks_cluster_name}-dns"

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_node_vm_size
  }

  kubernetes_version = var.aks_kubernetes_version

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
}

resource "azurerm_sql_server" "example" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password

  tags = {
    environment = "dev"
  }
}

resource "azurerm_sql_database" "example" {
  name                        = var.sql_database_name
  resource_group_name         = azurerm_resource_group.example.name
  location                    = azurerm_resource_group.example.location
  server_name                 = azurerm_sql_server.example.name
  requested_service_objective = "S0"  # Replace with the desired performance tier
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = "my-app-namespace"
  }
}

resource "kubernetes_secret" "sql-connection-secret" {
  metadata {
    name      = "sql-connection-secret"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  data = {
    connection-string = base64encode(
      "Server=${azurerm_sql_server.example.fqdn};Database=${azurerm_sql_database.example.name};User Id=${azurerm_sql_server.example.administrator_login};Password=${azurerm_sql_server.example.administrator_login_password};"
    )
  }
}

resource "kubernetes_deployment" "web-api" {
  metadata {
    name      = "web-api-deployment"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "web-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "web-api"
        }
      }

      spec {
        container {
          name  = "web-api-container"
          image = var.web_api_image

          ports {
            container_port = var.web_api_container_port
          }

          env {
            name  = "SQL_CONNECTION_STRING"
            value = base64decode(kubernetes_secret.sql-connection-secret.data["connection-string"])
          }
        }
      }
    }
  }
}

output "aks_kubeconfig" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw
}
