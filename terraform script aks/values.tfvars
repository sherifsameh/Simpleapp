# terraform.tfvars

# Azure configuration
subscription_id = "YOUR_SUBSCRIPTION_ID"
tenant_id       = "YOUR_TENANT_ID"
client_id       = "YOUR_CLIENT_ID"
client_secret   = "YOUR_CLIENT_SECRET"

# AKS configuration
aks_cluster_name       = "my-aks-cluster"
aks_node_count         = 2
aks_node_vm_size       = "Standard_DS2_v2"
aks_kubernetes_version = "1.21.0"

# SQL Server configuration
sql_server_name     = "my-sql-server"
sql_admin_login     = "sqladmin"
sql_admin_password  = "YourStrongPassword"
sql_database_name   = "my-sql-db"

# Web API application configuration
web_api_image        = "my-web-api-image:latest"
web_api_container_port = 80
