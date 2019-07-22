# az network nsg create --resource-group openshift --name app-nsg --tags app_security_group
resource "azurerm_network_security_group" "app" {
    name                = "app-nsg"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name app-nsg --name app-ssh --priority 500 --source-address-prefixes VirtualNetwork --destination-port-ranges 22 --access Allow --protocol Tcp --description "SSH from the bastion"
resource "azurerm_network_security_rule" "app-ssh" {
    name                        = "app-nsg-ssh"
    priority                    = 500
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.app.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name app-nsg --name app-kubelet --priority 525 --source-address-prefixes VirtualNetwork --destination-port-ranges 10250 --access Allow --protocol Tcp --description "kubelet"
resource "azurerm_network_security_rule" "app-kubelet" {
    name                        = "app-nsg-kubelet"
    priority                    = 525
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "10250"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.app.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name app-nsg --name app-sdn --priority 550 --source-address-prefixes VirtualNetwork --destination-port-ranges 4789 --access Allow --protocol Udp --description "ElasticSearch and ocp apps"
resource "azurerm_network_security_rule" "app-sdn" {
    name                        = "app-nsg-sdn"
    priority                    = 550
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Udp"
    source_port_range           = "*"
    destination_port_range      = "4789"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.app.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name app-nsg --name app-sdn --priority 575 --source-address-prefixes VirtualNetwork --destination-port-ranges 10256 --access Allow --protocol Tcp --description "Load Balancer health check"
resource "azurerm_network_security_rule" "app-lb-health" {
    name                        = "app-nsg-lb-health"
    priority                    = 575
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "10256"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.app.name}"
}
