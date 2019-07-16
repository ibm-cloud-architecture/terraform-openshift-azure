# az network nsg create --resource-group openshift --name node-nsg --tags node_security_group
resource "azurerm_network_security_group" "node" {
    name                = "node-nsg"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name node-nsg --name node-ssh --priority 500 --source-address-prefixes VirtualNetwork --destination-port-ranges 22 --access Allow --protocol Tcp --description "SSH from the bastion"
resource "azurerm_network_security_rule" "node-ssh" {
    name                        = "node-nsg-ssh"
    priority                    = 500
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.node.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name node-nsg --name node-kubelet --priority 525 --source-address-prefixes VirtualNetwork --destination-port-ranges 10250 --access Allow --protocol Tcp --description "kubelet"
resource "azurerm_network_security_rule" "node-kubelet" {
    name                        = "node-nsg-kubelet"
    priority                    = 525
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "10250"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.node.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name node-nsg --name node-sdn --priority 550 --source-address-prefixes VirtualNetwork --destination-port-ranges 4789 --access Allow --protocol Udp --description "ElasticSearch and ocp apps"
resource "azurerm_network_security_rule" "node-sdn" {
    name                        = "node-nsg-sdn"
    priority                    = 550
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Udp"
    source_port_range           = "*"
    destination_port_range      = "4789"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.node.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name node-nsg --name node-sdn --priority 575 --source-address-prefixes VirtualNetwork --destination-port-ranges 10256 --access Allow --protocol Tcp --description "Load Balancer health check"
resource "azurerm_network_security_rule" "node-lb-health" {
    name                        = "node-nsg-lb-health"
    priority                    = 575
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "10256"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.node.name}"
}
