# # az vm availability-set create --resource-group openshift --name ocp-master-instances
resource "azurerm_availability_set" "master" {
    name                = "master-availability-set"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    managed = true
}

# az network nic create --resource-group openshift --name ocp-master-${i}VMNic --vnet-name openshiftvnet --subnet ocp --network-security-group master-nsg --lb-name OcpMasterLB --lb-address-pools masterAPIBackend --internal-dns-name ocp-master-${i} --public-ip-address
resource "azurerm_network_interface" "master" {
    count                     = "${var.master_count}"
    name                      = "openshift-master-${count.index + 1}-nic"
    location                  = "${var.datacenter}"
    resource_group_name       = "${azurerm_resource_group.openshift.name}"
    network_security_group_id = "${azurerm_network_security_group.master.id}"
    internal_dns_name_label = "master-${count.index + 1}"

    ip_configuration {
        name                          = "default"
        subnet_id                     = "${azurerm_subnet.master.id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "master" {
    count                   = "${var.master_count}"
    network_interface_id    = "${element(azurerm_network_interface.master.*.id,count.index)}"
    ip_configuration_name   = "default"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.masterAPIBackend.id}"
}

# az vm create --resource-group openshift --name ocp-master-$i --availability-set ocp-master-instances --size Standard_D4s_v3 --image RedHat:RHEL:7-RAW:latest --admin-user cloud-user --ssh-key /root/.ssh/id_rsa.pub --data-disk-sizes-gb 32 --nics ocp-master-${i}VMNic
resource "azurerm_virtual_machine" "master" {
    count                   = "${var.master_count}"
    name                    = "ocp-master-${count.index + 1}"
    location                = "${var.datacenter}"
    resource_group_name     = "${azurerm_resource_group.openshift.name}"
    network_interface_ids   = ["${element(azurerm_network_interface.master.*.id,count.index)}"]
    vm_size                 = "${var.master_flavor}"
    availability_set_id     = "${azurerm_availability_set.master.id}"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "RedHat"
        offer     = "RHEL"
        sku       = "7-RAW"
        version   = "latest"
    }

    storage_os_disk {
        name              = "master-os-disk-${count.index + 1}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_data_disk {
        name              = "master-docker-disk-${count.index + 1}"
        create_option     = "Empty"
        managed_disk_type = "Standard_LRS"
        lun               = 0
        disk_size_gb      = 32
    }

    storage_data_disk {
        name              = "master-etcd-disk-${count.index + 1}"
        create_option     = "Empty"
        managed_disk_type = "Standard_LRS"
        lun               = 1
        disk_size_gb      = 32
    }

    os_profile {
        computer_name  = "master-${count.index + 1}"
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

resource "azurerm_dns_a_record" "master" {
    count               = "${var.master_count}"
    name                = "master-${count.index + 1}"
    zone_name           = "${azurerm_dns_zone.private.name}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    ttl                 = 300
    records             = ["${element(azurerm_network_interface.master.*.private_ip_address,count.index)}"]
}
