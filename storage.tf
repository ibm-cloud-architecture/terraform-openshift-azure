# az vm availability-set create --resource-group openshift --name ocp-app-instances
resource "azurerm_availability_set" "storage" {
    count               = "${var.storage["nodes"] == "0" ? 0 : 1}"
    name                = "storage-availability-set"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    managed             = true
}

# az network nic create --resource-group openshift --name ocp-master-${i}VMNic --vnet-name openshiftvnet --subnet ocp --network-security-group master-nsg --lb-name OcpMasterLB --lb-address-pools masterAPIBackend --internal-dns-name ocp-master-${i} --public-ip-address
resource "azurerm_network_interface" "storage" {
    count                     = "${var.storage["nodes"] == "0" ? 0 : var.storage["nodes"]}"
    name                      = "openshift-storage-${count.index + 1}-nic"
    location                  = "${var.datacenter}"
    resource_group_name       = "${azurerm_resource_group.openshift.name}"
    network_security_group_id = "${azurerm_network_security_group.storage.0.id}"
    internal_dns_name_label = "storage-${count.index + 1}"

    ip_configuration {
        name                          = "default"
        subnet_id                     = "${azurerm_subnet.storage.id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "storage" {
    count                   = "${var.storage["nodes"] == "0" ? 0 : var.storage["nodes"]}"
    network_interface_id    = "${element(azurerm_network_interface.storage.*.id,count.index)}"
    ip_configuration_name   = "default"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.routerBackend.id}"
}

# az vm create --resource-group openshift --name ocp-master-$i --availability-set ocp-master-instances --size Standard_D4s_v3 --image RedHat:RHEL:7-RAW:latest --admin-user cloud-user --ssh-key /root/.ssh/id_rsa.pub --data-disk-sizes-gb 32 --nics ocp-master-${i}VMNic
resource "azurerm_virtual_machine" "storage" {
    count                   = "${var.storage["nodes"] == "0" ? 0 : var.storage["nodes"]}"
    name                    = "${var.hostname_prefix}-storage-${count.index + 1}"
    location                = "${var.datacenter}"
    resource_group_name     = "${azurerm_resource_group.openshift.name}"
    network_interface_ids   = ["${element(azurerm_network_interface.storage.*.id,count.index)}"]
    vm_size                 = "${var.storage["flavor"]}"
    availability_set_id     = "${azurerm_availability_set.storage.0.id}"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "RedHat"
        offer     = "RHEL"
        sku       = "7-RAW"
        version   = "latest"
    }

    storage_os_disk {
        name              = "storage-os-disk-${count.index + 1}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_data_disk {
        name              = "storage-docker-disk-${count.index + 1}"
        create_option     = "Empty"
        managed_disk_type = "Standard_LRS"
        lun               = 0
        disk_size_gb      = "${var.storage["docker_disk_size"]}"
    }

    storage_data_disk {
        name              = "storage-gluster-disk-${count.index + 1}"
        create_option     = "Empty"
        managed_disk_type = "Premium_LRS"
        lun               = 1
        disk_size_gb      = "${var.storage["gluster_disk_size"]}"
    }

    os_profile {
        computer_name  = "${var.hostname_prefix}-storage-${count.index + 1}"
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

resource "azurerm_dns_a_record" "storage" {
    count               = "${var.storage["nodes"]}"
    name                = "${var.hostname_prefix}-storage-${count.index + 1}"
    zone_name           = "${azurerm_dns_zone.private.name}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    ttl                 = 300
    records             = ["${element(azurerm_network_interface.storage.*.private_ip_address,count.index)}"]
}

resource "null_resource" "copy_ssh_key_storage" {
    count    = "${var.openshift_vm_admin_user == "root" ? 0 : var.storage["nodes"]}"
    connection {
        type     = "ssh"
        user     = "${var.openshift_vm_admin_user}"
        host     = "${element(azurerm_network_interface.storage.*.private_ip_address, count.index)}"
        private_key = "${var.bastion_private_ssh_key}"
        bastion_host = "${azurerm_public_ip.bastion.ip_address}"
        bastion_host_key = "${var.bastion_private_ssh_key}"
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
    depends_on = [
        "azurerm_virtual_machine.bastion",
        "azurerm_virtual_machine.storage",
    ]
}
