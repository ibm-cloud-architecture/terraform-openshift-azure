provider "azurerm" { }

# az group create --name openshift --location "East US"
resource "azurerm_resource_group" "openshift" {
    name                = "${var.cluster_resource_group}"
    location            = "${var.datacenter}"
}

data "azurerm_resource_group" "keyvault" {
  name = "${var.keyvault_resource_group}"
}
data "azurerm_client_config" "current" {}
data "azurerm_key_vault" "openshift" {
  name                = "${var.keyvault_name}"
  resource_group_name = "${data.azurerm_resource_group.keyvault.name}"
}
data "azurerm_key_vault_secret" "openshift" {
  name         = "aadClientSecret"
  key_vault_id = "${data.azurerm_key_vault.openshift.id}"
}

output "secret_value" {
  value = "${data.azurerm_key_vault_secret.openshift.value}"
}

resource "azurerm_storage_account" "registry" {
  name                     = "ncolonregistry"
  resource_group_name      = "${azurerm_resource_group.openshift.name}"
  location                 = "${var.datacenter}"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

output "registry_primary_key" {
    value = "${azurerm_storage_account.registry.primary_access_key}"
}
