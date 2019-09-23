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
    name                    = "${var.hostname_prefix}-bastion"
    location                = "${var.datacenter}"
    resource_group_name     = "${azurerm_resource_group.openshift.name}"
    network_interface_ids   = ["${azurerm_network_interface.bastion.id}"]
    vm_size                 = "${var.bastion["flavor"]}"

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

    storage_data_disk {
        name              = "bastion-docker-disk"
        create_option     = "Empty"
        managed_disk_type = "Standard_LRS"
        lun               = 0
        disk_size_gb      = "${var.bastion["docker_disk_size"]}"
    }

    os_profile {
        computer_name  = "${var.hostname_prefix}-bastion"
        admin_username = "${var.openshift_vm_admin_user}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path = "/home/${var.openshift_vm_admin_user}/.ssh/authorized_keys"
            key_data = "${var.bastion_public_ssh_key}"
        }
    }
}

resource "azurerm_private_dns_a_record" "bastion" {
    name                = "${var.hostname_prefix}-bastion"
    zone_name           = "${azurerm_private_dns_zone.private.name}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    ttl                 = 300
    records             = ["${azurerm_network_interface.bastion.private_ip_address}"]
}




resource "null_resource" "copy_ssh_key_bastion" {
    count    = "${var.openshift_vm_admin_user == "root" ? 0 : 1}"
    connection {
        type     = "ssh"
        user     = "${var.openshift_vm_admin_user}"
        host     = "${azurerm_public_ip.bastion.ip_address}"
        private_key = "${var.bastion_private_ssh_key}"
    }

    provisioner "file" {
        content     = "${var.bastion_private_ssh_key}"
        destination = "~/.ssh/id_rsa"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod 600 ~/.ssh/id_rsa",
            "sudo mkdir /root/.ssh",
            "sudo cp ~/.ssh/authorized_keys /root/.ssh/",
            "sudo cp ~/.ssh/id_rsa /root/.ssh/id_rsa",
            "sudo chmod 600 /root/.ssh/id_rsa",
        ]
    }
    depends_on = ["azurerm_virtual_machine.bastion"]
}
