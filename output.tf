#################################################
# Output Bastion Node
#################################################

output "bastion_public_ip" {
    value = "${azurerm_public_ip.bastion.ip_address}"
}

output "bastion_private_ip" {
  value = "${azurerm_network_interface.bastion.private_ip_address}"
}

output "bastion_hostname" {
  value = "${azurerm_virtual_machine.bastion.name}"
}

# #################################################
# # Output Master Node
# #################################################
output "master_private_ip" {
  value = "${azurerm_network_interface.master.*.private_ip_address}"
}

output "master_hostname" {
  value = "${azurerm_virtual_machine.master.*.name}"
}

output "master_public_ip" {
  value = []
}


#################################################
# Output Infra Node
#################################################
output "infra_private_ip" {
  value = "${azurerm_network_interface.infra.*.private_ip_address}"
}

output "infra_hostname" {
  value = "${azurerm_virtual_machine.infra.*.name}"
}

output "infra_public_ip" {
  value = []
}

# #################################################
# # Output worker Node
# #################################################
output "worker_private_ip" {
  value = "${azurerm_network_interface.worker.*.private_ip_address}"
}

output "worker_hostname" {
  value = "${azurerm_virtual_machine.worker.*.name}"
}

output "worker_public_ip" {
  value = []
}

# #################################################
# # Output Storage Node
# #################################################
output "storage_private_ip" {
  value = "${azurerm_network_interface.storage.*.private_ip_address}"
}

output "storage_hostname" {
  value = "${azurerm_virtual_machine.storage.*.name}"
}

output "storage_public_ip" {
  value = []
}

#################################################
# Output LBaaS VIP
#################################################
output "public_master_vip" {
    value = "${azurerm_public_ip.masterExternalLB.fqdn}"
}

output "public_worker_vip" {
    value = "${azurerm_public_ip.routerExternalLB.fqdn}"
}

#################################################
# Output Azure CloudProvider
#################################################
output "azure_client_id" {
    value = "${azuread_service_principal.auth.application_id}"
}

output "azure_client_secret" {
    value = "${azuread_service_principal_password.auth.value}"
    sensitive = true
}

output "azure_tenant_id" {
    value = "${data.azurerm_client_config.current.tenant_id}"
}

output "azure_subscription_id" {
    value = "${data.azurerm_client_config.current.subscription_id}"
}

output "azure_storage_account" {
    value = "${azurerm_storage_account.registry.name}"
}

output "azure_storage_accountkey" {
    value = "${azurerm_storage_account.registry.primary_access_key}"
}


output "module_completed" {
  value = "${join(",", concat(
    "${list(azurerm_virtual_machine.bastion.id)}",
    "${azurerm_virtual_machine.master.*.private_ip_address}",
    "${azurerm_virtual_machine.infra.*.private_ip_address}",
    "${azurerm_virtual_machine.worker.*.private_ip_address}",
    "${azurerm_virtual_machine.storage.*.private_ip_address}",
  ))}"
}