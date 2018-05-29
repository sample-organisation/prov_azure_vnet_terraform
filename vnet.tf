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
