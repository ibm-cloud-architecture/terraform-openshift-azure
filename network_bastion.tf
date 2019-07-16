# az network nsg create --resource-group openshift --name bastion-nsg --tags bastion_nsg
resource "azurerm_network_security_group" "bastion" {
    name                = "bastion-nsg"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name bastion-nsg --name bastion-nsg-ssh  --priority 500 --destination-port-ranges 22 --access Allow --protocol Tcp --description "SSH access from Internet"
resource "azurerm_network_security_rule" "bastion-ssh" {
    name                        = "bastion-nsg-ssh"
    priority                    = 500
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.bastion.name}"
}
