provider "azurerm" {
  subscription_id = "${var.azure_subscription_id}"
  client_id = "${var.azure_client_id}"
  client_secret = "${var.azure_client_secret}"
  tenant_id = "${var.azure_tenant_id}"
}

resource "azurerm_resource_group" "resource_group_name" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_virtual_network" "vnet_name" {
  name                = "${var.vnet_name}"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.vnet_location}"
  resource_group_name = "${azurerm_resource_group.resource_group_name.name}"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_subnet" "demo_subnet_tf" {
    name                 = "demo_subnet_tf"
    resource_group_name  = "${azurerm_resource_group.resource_group_name.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet_name.name}"
    address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "demo_public_ip_tf" {
    name                         = "demo_public_ip_tf"
    location                     = "eastus"
    resource_group_name          = "${azurerm_resource_group.resource_group_name.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_security_group" "demo_public_nsg_tf" {
    name                = "demo_public_nsg_tf"
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.resource_group_name.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface" "demo_nic_tf" {
    name                = "demo_nic_tf"
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.resource_group_name.name}"

    ip_configuration {
        name                          = "demo_ip_configuration"
        subnet_id                     = "${azurerm_subnet.demo_subnet_tf.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.demo_public_ip_tf.id}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

# Generate a randomID for naming the storageaccount
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.resource_group_name.name}"
    }

    byte_length = 8
}

# Create a storage account to store the boot diagnostics for a VM
resource "azurerm_storage_account" "demo_storage_account_tf" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.resource_group_name.name}"
    location            = "eastus"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "Terraform Demo"
    }
}
