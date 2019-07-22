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
# # Output App Node
# #################################################
output "app_private_ip" {
  value = "${azurerm_network_interface.app.*.private_ip_address}"
}

output "app_hostname" {
  value = "${azurerm_virtual_machine.app.*.name}"
}

output "app_public_ip" {
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

output "public_app_vip" {
    value = "${azurerm_public_ip.routerExternalLB.fqdn}"
}
