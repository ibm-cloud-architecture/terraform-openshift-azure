# az network nsg create --resource-group openshift --name master-nsg --tags master_security_group
resource "azurerm_network_security_group" "master" {
    name                = "master-nsg"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name master-nsg --name master-ssh --priority 500 --source-address-prefixes VirtualNetwork --destination-port-ranges 22 --access Allow --protocol Tcp --description "SSH from the bastion"
resource "azurerm_network_security_rule" "master-ssh" {
    name                        = "master-nsg-ssh"
    priority                    = 500
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.master.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name master-nsg --name master-etcd --priority 525 --source-address-prefixes VirtualNetwork --destination-port-ranges 2379 2380 --access Allow --protocol Tcp --description "ETCD service ports"
resource "azurerm_network_security_rule" "master-etcd" {
    name                        = "master-nsg-etcd"
    priority                    = 525
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_ranges     = ["2379", "2380"]
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.master.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name master-nsg --name master-api --priority 550 --destination-port-ranges 443 --access Allow --protocol Tcp --description "API port"
resource "azurerm_network_security_rule" "master-api" {
    name                        = "master-nsg-api"
    priority                    = 550
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "443"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.master.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name master-nsg --name master-api-lb --source-address-prefixes VirtualNetwork --priority 575 --destination-port-ranges 443 --access Allow --protocol Tcp --description "API port"
resource "azurerm_network_security_rule" "master-api-lb" {
    name                        = "master-nsg-api-lb"
    priority                    = 575
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "443"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.master.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name master-nsg --name master-ocp-tcp --priority 600 --source-address-prefixes VirtualNetwork --destination-port-ranges 8053 --access Allow --protocol Tcp --description "TCP DNS and fluentd"
resource "azurerm_network_security_rule" "master-ocp-tcp" {
    name                        = "master-nsg-ocp-tcp"
    priority                    = 600
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "8053"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.master.name}"
}
# az network nsg rule create --resource-group openshift --nsg-name master-nsg --name master-ocp-udp --priority 625 --source-address-prefixes VirtualNetwork --destination-port-ranges 8053 --access Allow --protocol Udp --description "UDP DNS and fluentd"
resource "azurerm_network_security_rule" "master-ocp-udp" {
    name                        = "master-nsg-ocp-udp"
    priority                    = 625
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Udp"
    source_port_range           = "*"
    destination_port_range      = "8053"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.master.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name master-nsg --name node-kubelet --priority 650 --source-address-prefixes VirtualNetwork --destination-port-ranges 10250 --access Allow --protocol Tcp --description "kubelet"
resource "azurerm_network_security_rule" "master-node-kubelet" {
    name                        = "master-nsg-node-kubelet"
    priority                    = 650
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "10250"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.master.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name master-nsg --name node-sdn --priority 675 --source-address-prefixes VirtualNetwork --destination-port-ranges 4789 --access Allow --protocol Udp --description "OpenShift sdn"
resource "azurerm_network_security_rule" "master-node-sdn" {
    name                        = "master-nsg-node-sdn"
    priority                    = 675
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Udp"
    source_port_range           = "*"
    destination_port_range      = "4789"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.master.name}"
}
