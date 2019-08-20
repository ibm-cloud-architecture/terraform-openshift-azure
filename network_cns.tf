# az network nsg create --resource-group openshift --name storage-nsg --tags node_security_group
resource "azurerm_network_security_group" "storage" {
    count               = "${var.storage["nodes"] == "0" ? 0 : 1}"
    name                = "storage-nsg"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name storage-nsg --name node-ssh --priority 500 --source-address-prefixes VirtualNetwork --destination-port-ranges 22 --access Allow --protocol Tcp --description "SSH from the bastion"
resource "azurerm_network_security_rule" "storage-ssh" {
    count                       = "${var.storage["nodes"] == "0" ? 0 : 1}"
    name                        = "storage-nsg-ssh"
    priority                    = 500
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.storage.0.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name storage-nsg --name node-kubelet --priority 525 --source-address-prefixes VirtualNetwork --destination-port-ranges 10250 --access Allow --protocol Tcp --description "kubelet"
resource "azurerm_network_security_rule" "storage-kubelet" {
    count                       = "${var.storage["nodes"] == "0" ? 0 : 1}"
    name                        = "storage-nsg-kubelet"
    priority                    = 525
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "10250"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.storage.0.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name storage-nsg --name node-sdn --priority 550 --source-address-prefixes VirtualNetwork --destination-port-ranges 4789 --access Allow --protocol Udp --description "ElasticSearch and ocp apps"
resource "azurerm_network_security_rule" "storage-sdn" {
    count                       = "${var.storage["nodes"] == "0" ? 0 : 1}"
    name                        = "storage-nsg-sdn"
    priority                    = 550
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Udp"
    source_port_range           = "*"
    destination_port_range      = "4789"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.storage.0.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name storage-nsg --name gluster-ssh --priority 575 --source-address-prefixes VirtualNetwork --destination-port-ranges 2222 --access Allow --protocol Tcp --description "Gluster SSH"
resource "azurerm_network_security_rule" "storage-gluster-ssh" {
    count                       = "${var.storage["nodes"] == "0" ? 0 : 1}"
    name                        = "storage-nsg-gluster-ssh"
    priority                    = 575
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "2222"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.storage.0.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name storage-nsg --name gluster-daemon --priority 600 --source-address-prefixes VirtualNetwork --destination-port-ranges 24008 --access Allow --protocol Tcp --description "Gluster Daemon"

resource "azurerm_network_security_rule" "storage-gluster-daemon" {
    count                       = "${var.storage["nodes"] == "0" ? 0 : 1}"
    name                        = "storage-nsg-gluster-daemon"
    priority                    = 600
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "24008"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.storage.0.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name storage-nsg --name gluster-mgmt --priority 625 --source-address-prefixes VirtualNetwork --destination-port-ranges 24009 --access Allow --protocol Tcp --description "Gluster Management"
resource "azurerm_network_security_rule" "storage-gluster-mgmt" {
    count                       = "${var.storage["nodes"] == "0" ? 0 : 1}"
    name                        = "storage-nsg-gluster-mgmt"
    priority                    = 625
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "24009"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.storage.0.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name storage-nsg --name gluster-client --priority 650 --source-address-prefixes VirtualNetwork --destination-port-ranges  49152-49664 --access Allow --protocol Tcp --description "Gluster Clients"
resource "azurerm_network_security_rule" "storage-gluster-clients" {
    count                       = "${var.storage["nodes"] == "0" ? 0 : 1}"
    name                        = "storage-nsg-gluster-clients"
    priority                    = 650
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "49152-49664"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.storage.0.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name storage-nsg --name portmap-tcp  --priority 675 --source-address-prefixes VirtualNetwork --destination-port-ranges  111 --access Allow --protocol Tcp --description "Portmap tcp"
resource "azurerm_network_security_rule" "storage-gluster-portman-tcp" {
    count                       = "${var.storage["nodes"] == "0" ? 0 : 1}"
    name                        = "storage-nsg-portmap-tcp"
    priority                    = 675
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "111"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.storage.0.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name storage-nsg --name portmap-udp --priority 700 --source-address-prefixes VirtualNetwork --destination-port-ranges  111 --access Allow --protocol Udp --description "Portmap udp"
resource "azurerm_network_security_rule" "storage-gluster-portmap-udp" {
    count                       = "${var.storage["nodes"] == "0" ? 0 : 1}"
    name                        = "storage-nsg-portmap-udp"
    priority                    = 700
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Udp"
    source_port_range           = "*"
    destination_port_range      = "111"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.storage.0.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name storage-nsg --name gluster-iscsi --priority 725 --source-address-prefixes VirtualNetwork --destination-port-ranges  3260 --access Allow --protocol Tcp --description "Gluster Blocks"
resource "azurerm_network_security_rule" "storage-gluster-gluster-iscsi" {
    count                       = "${var.storage["nodes"] == "0" ? 0 : 1}"
    name                        = "storage-nsg-gluster-iscsi"
    priority                    = 725
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "3260"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.storage.0.name}"
}

# az network nsg rule create --resource-group openshift --nsg-name storage-nsg --name gluster-block --priority 750 --source-address-prefixes VirtualNetwork --destination-port-ranges  24010 --access Allow --protocol Tcp --description "Gluster Block"
resource "azurerm_network_security_rule" "storage-gluster-gluster-block" {
    count                       = "${var.storage["nodes"] == "0" ? 0 : 1}"
    name                        = "storage-nsg-gluster-block"
    priority                    = 750
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "24010"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.openshift.name}"
    network_security_group_name = "${azurerm_network_security_group.storage.0.name}"
}
