# az network public-ip create --name bastion-static --resource-group openshift --allocation-method Static
resource "azurerm_public_ip" "bastion" {
    name                = "bastion-static"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    allocation_method   = "Static"
    sku                 = "standard"
}

# az network nic create --name bastion-VMNic --resource-group openshift --subnet ocp --vnet-name openshiftvnet --network-security-group bastion-nsg --public-ip-address bastion-static
resource "azurerm_network_interface" "bastion" {
    name                      = "openshift-bastion-nic"
    location                  = "${var.datacenter}"
    resource_group_name       = "${azurerm_resource_group.openshift.name}"
    network_security_group_id = "${azurerm_network_security_group.bastion.id}"
    internal_dns_name_label   = "bastion"

    ip_configuration {
        name                          = "default"
        public_ip_address_id          = "${azurerm_public_ip.bastion.id}"
        subnet_id                     = "${azurerm_subnet.master.id}"
        private_ip_address_allocation = "dynamic"
    }
}

# az vm create --resource-group openshift --name bastion --size Standard_D1 --image RedHat:RHEL:7-RAW:latest --admin-user cloud-user --ssh-key /root/.ssh/id_rsa.pub --nics bastion-VMNic

resource "azurerm_virtual_machine" "bastion" {
    name                    = "ocp-bastion"
    location                = "${var.datacenter}"
    resource_group_name     = "${azurerm_resource_group.openshift.name}"
    network_interface_ids   = ["${azurerm_network_interface.bastion.id}"]
    vm_size                 = "${var.bastion_flavor}"

    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "RedHat"
        offer     = "RHEL"
        sku       = "7-RAW"
        version   = "latest"
    }

    storage_os_disk {
        name              = "bastion-os-disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name  = "bastion"
        admin_username = "${var.openshift_vm_admin_user}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path = "/home/${var.openshift_vm_admin_user}/.ssh/authorized_keys"
            key_data = "${file("~/.ssh/openshift_rsa.pub")}"
        }
    }
}

resource "azurerm_dns_a_record" "bastion" {
    name                = "bastion"
    zone_name           = "${azurerm_dns_zone.private.name}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    ttl                 = 300
    records             = ["${azurerm_network_interface.bastion.private_ip_address}"]
}
