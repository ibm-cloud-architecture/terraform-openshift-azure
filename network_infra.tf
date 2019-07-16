# az network nsg create --resource-group openshift --name infra-node-nsg --tags infra_security_group
resource "azurerm_network_security_group" "infra" {
    name                = "infra-nsg"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name infra-node-nsg --name infra-ssh --priority 500 --source-address-prefixes VirtualNetwork --destination-port-ranges 22 --access Allow --protocol Tcp --description "SSH from the bastion"
resource "azurerm_network_security_rule" "infra-ssh" {
    name                        = "infra-nsg-ssh"
    priority                    = 500
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.infra.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name infra-node-nsg --name router-ports --priority 525 --source-address-prefixes AzureLoadBalancer --destination-port-ranges 80 443 --access Allow --protocol Tcp --description "OpenShift router"
resource "azurerm_network_security_rule" "infra-router-ports" {
    name                        = "infra-nsg-router-ports"
    priority                    = 525
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_ranges     = ["80", "443"]
    source_address_prefix       = "AzureLoadBalancer"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.infra.name}"
}
# az network nsg rule create --resource-group openshift --nsg-name infra-node-nsg --name infra-ports --priority 550 --source-address-prefixes VirtualNetwork --destination-port-ranges 9200 9300 --access Allow --protocol Tcp --description "ElasticSearch"
resource "azurerm_network_security_rule" "infra-elasticsearch" {
    name                        = "infra-nsg-elasticsearch"
    priority                    = 550
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_ranges     = ["9200", "9300"]
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.infra.name}"
}
# az network nsg rule create --resource-group openshift --nsg-name infra-node-nsg --name node-kubelet --priority 575 --source-address-prefixes VirtualNetwork --destination-port-ranges 10250 --access Allow --protocol Tcp --description "kubelet"
resource "azurerm_network_security_rule" "infra-kubelet" {
    name                        = "infra-nsg-kubelet"
    priority                    = 575
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "10250"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.infra.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name infra-node-nsg --name node-sdn --priority 600 --source-address-prefixes VirtualNetwork --destination-port-ranges 4789 --access Allow --protocol Udp --description "OpenShift sdn"
resource "azurerm_network_security_rule" "infra-sdn" {
    name                        = "infra-nsg-sdn"
    priority                    = 600
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Udp"
    source_port_range           = "*"
    destination_port_range      = "4789"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.infra.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name infra-node-nsg --name router-ports --priority 625 --destination-port-ranges 80 443 --access Allow --protocol Tcp --description "OpenShift router"
resource "azurerm_network_security_rule" "infra-router-ports-public" {
    name                        = "infra-nsg-router-ports-public"
    priority                    = 625
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_ranges     = ["80", "443"]
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.infra.name}"
}
