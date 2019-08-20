provider "azurerm" { }
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "primary" {}

# az group create --name openshift --location "East US"
resource "azurerm_resource_group" "openshift" {
    name                = "${var.cluster_resource_group}"
    location            = "${var.datacenter}"
}

# data "azurerm_resource_group" "keyvault" {
#   name = "${var.keyvault_resource_group}"
# }
#
# data "azurerm_key_vault" "openshift" {
#   name                = "${var.keyvault_name}"
#   resource_group_name = "${data.azurerm_resource_group.keyvault.name}"
# }
# data "azurerm_key_vault_secret" "openshift" {
#   name         = "aadClientSecret"
#   key_vault_id = "${data.azurerm_key_vault.openshift.id}"
# }
#
# resource "azurerm_storage_account" "registry" {
#   name                     = "ncolonregistry"
#   resource_group_name      = "${azurerm_resource_group.openshift.name}"
#   location                 = "${var.datacenter}"
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
# }

resource "random_uuid" "password" { }

resource "azuread_application" "auth" {
  name = "auth"
}

resource "azuread_service_principal" "auth" {
  application_id = "${azuread_application.auth.application_id}"
}

resource "azuread_service_principal_password" "auth" {
  service_principal_id = "${azuread_service_principal.auth.id}"
  value                = "${random_uuid.password.result}"
  end_date_relative    = "43800h"
}

resource "azurerm_role_assignment" "auth" {
  scope                = "${azurerm_resource_group.openshift.id}"
  role_definition_name = "Contributor"
  principal_id         = "${azuread_service_principal.auth.id}"
}

resource "azurerm_storage_account" "registry" {
  name                     = "ocpregistry"
  resource_group_name      = "${azurerm_resource_group.openshift.name}"
  location                 = "${var.datacenter}"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
