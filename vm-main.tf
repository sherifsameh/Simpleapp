# Define the provider for Azure
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create a subnet
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP address
resource "azurerm_public_ip" "example" {
  name                = "example-publicip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

# Create a network security group (NSG)
resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create a network security group rule to allow SQL Server traffic (adjust ports as needed)
resource "azurerm_network_security_rule" "sql" {
  name                        = "allow-sql"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
}

# Create a virtual machine scale set
resource "azurerm_windows_virtual_machine_scale_set" "example" {
  name                = "example-vmss"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 {
    tier = "Standard"
    capacity = 2
  }
  instances           = 2
  upgrade_policy_mode = "Automatic"
  admin_username      = "adminuser"
  admin_password      = "Password12345!"  # Change this to a secure password
  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2019-WS2019"
    sku       = "Standard"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  network_profile {
    name    = "example-network-profile"
    primary = true

    ip_configuration {
      name      = "example-ip-configuration"
      primary   = true
      subnet_id = azurerm_subnet.example.id
      public_ip_address_id = azurerm_public_ip.example.id
      network_security_group_ids = [azurerm_network_security_group.example.id]
    }
  }

  extension {
    name                 = "customScript"
    publisher            = "Microsoft.Compute"
    virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.example.id
    type                 = "CustomScriptExtension"
    type_handler_version = "1.10"

    settings = <<SETTINGS
        {
            "script": "your_script_to_install_sql_server.ps1"
        }
SETTINGS

    protected_settings = <<PROTECTED_SETTINGS
        {}
PROTECTED_SETTINGS
  }

}

# Output the public IP address of the VMSS instances
output "public_ip_addresses" {
  value = azurerm_windows_virtual_machine_scale_set.example.network_profile[*].ip_configuration[0].public_ip_address
}
