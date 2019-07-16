# az vm availability-set create --resource-group openshift --name ocp-app-instances
resource "azurerm_availability_set" "storage" {
    name                = "storage-availability-set"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    managed             = true
}

# az network nic create --resource-group openshift --name ocp-master-${i}VMNic --vnet-name openshiftvnet --subnet ocp --network-security-group master-nsg --lb-name OcpMasterLB --lb-address-pools masterAPIBackend --internal-dns-name ocp-master-${i} --public-ip-address
resource "azurerm_network_interface" "storage" {
    count                     = "${var.storage_count == "0" ? 0 : var.storage_count}"
    name                      = "openshift-storage-${count.index + 1}-nic"
    location                  = "${var.datacenter}"
    resource_group_name       = "${azurerm_resource_group.openshift.name}"
    network_security_group_id = "${azurerm_network_security_group.storage.id}"
    internal_dns_name_label = "storage-${count.index + 1}"

    ip_configuration {
        name                          = "default"
        subnet_id                     = "${azurerm_subnet.storage.id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "storage" {
    count                   = "${var.storage_count == "0" ? 0 : var.storage_count}"
    network_interface_id    = "${element(azurerm_network_interface.storage.*.id,count.index)}"
    ip_configuration_name   = "default"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.routerBackend.id}"
}

# az vm create --resource-group openshift --name ocp-master-$i --availability-set ocp-master-instances --size Standard_D4s_v3 --image RedHat:RHEL:7-RAW:latest --admin-user cloud-user --ssh-key /root/.ssh/id_rsa.pub --data-disk-sizes-gb 32 --nics ocp-master-${i}VMNic
resource "azurerm_virtual_machine" "storage" {
    count                   = "${var.storage_count == "0" ? 0 : var.storage_count}"
    name                    = "ocp-storage-${count.index + 1}"
    location                = "${var.datacenter}"
    resource_group_name     = "${azurerm_resource_group.openshift.name}"
    network_interface_ids   = ["${element(azurerm_network_interface.storage.*.id,count.index)}"]
    vm_size                 = "${var.storage_flavor}"
    availability_set_id     = "${azurerm_availability_set.storage.id}"
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
        disk_size_gb      = 64
    }

    storage_data_disk {
        name              = "storage-gluster-disk-${count.index + 1}"
        create_option     = "Empty"
        managed_disk_type = "Premium_LRS"
        lun               = 1
        disk_size_gb      = 512
    }

    os_profile {
        computer_name  = "storage-${count.index + 1}"
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
