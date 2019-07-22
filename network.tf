# az network vnet create --name openshiftvnet --resource-group openshift --subnet-name ocp --address-prefix 10.0.0.0/16 --subnet-prefix 10.0.0.0/24
resource "azurerm_virtual_network" "openshift" {
    name                = "openshiftvnet"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "master" {
  name                 = "master-subnet"
  resource_group_name  = "${azurerm_resource_group.openshift.name}"
  virtual_network_name = "${azurerm_virtual_network.openshift.name}"
  address_prefix       = "${var.openshift_master_cidr}"
}

resource "azurerm_subnet" "infra" {
  name                 = "infra-subnet"
  resource_group_name  = "${azurerm_resource_group.openshift.name}"
  virtual_network_name = "${azurerm_virtual_network.openshift.name}"
  address_prefix       = "${var.openshift_infra_cidr}"
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = "${azurerm_resource_group.openshift.name}"
  virtual_network_name = "${azurerm_virtual_network.openshift.name}"
  address_prefix       = "${var.openshift_node_cidr}"
}

resource "azurerm_subnet" "storage" {
  name                 = "storage-subnet"
  resource_group_name  = "${azurerm_resource_group.openshift.name}"
  virtual_network_name = "${azurerm_virtual_network.openshift.name}"
  address_prefix       = "${var.openshift_storage_cidr}"
}

# az network public-ip create --resource-group openshift --name masterExternalLB --allocation-method Static
resource "azurerm_public_ip" "masterExternalLB" {
    name                = "masterExternalLB"
    domain_name_label   = "master-${var.hostname_prefix}"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    allocation_method   = "Static"
    sku                 = "standard"
}

# az network lb create --resource-group openshift --name OcpMasterLB --public-ip-address masterExternalLB --frontend-ip-name masterApiFrontend --backend-pool-name masterAPIBackend
resource "azurerm_lb" "master" {
    name                = "OcpMasterLB"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    sku                 = "standard"

    frontend_ip_configuration {
        name                 = "masterApiFrontend"
        public_ip_address_id = "${azurerm_public_ip.masterExternalLB.id}"
    }
}

resource "azurerm_lb_backend_address_pool" "masterAPIBackend" {
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    loadbalancer_id     = "${azurerm_lb.master.id}"
    name                = "masterAPIBackend"
}

# az network lb probe create --resource-group openshift --lb-name OcpMasterLB --name masterHealthProbe --protocol tcp --port 443
resource "azurerm_lb_probe" "masterHealthProbe" {
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    loadbalancer_id     = "${azurerm_lb.master.id}"
    name                = "masterHealthProbe"
    port                = 443
    protocol            = "Tcp"
}

# az network lb rule create --resource-group openshift --lb-name OcpMasterLB --name ocpApiHealth --protocol tcp --frontend-port 443 --backend-port 443 --frontend-ip-name masterApiFrontend --backend-pool-name masterAPIBackend --probe-name masterHealthProbe --load-distribution SourceIPProtocol
resource "azurerm_lb_rule" "ocpApiHealth" {
    resource_group_name            = "${azurerm_resource_group.openshift.name}"
    loadbalancer_id                = "${azurerm_lb.master.id}"
    name                           = "ocpApiHealth"
    protocol                       = "Tcp"
    frontend_port                  = 443
    backend_port                   = 443
    frontend_ip_configuration_name = "masterApiFrontend"
    backend_address_pool_id        = "${azurerm_lb_backend_address_pool.masterAPIBackend.id}"
    probe_id                       = "${azurerm_lb_probe.masterHealthProbe.id}"
    load_distribution              = "SourceIPProtocol"
}

# az network public-ip create --resource-group openshift --name routerExternalLB --allocation-method Static
resource "azurerm_public_ip" "routerExternalLB" {
    name                = "routerExternalLB"
    domain_name_label   = "app-${var.hostname_prefix}"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    allocation_method   = "Static"
    sku                 = "standard"
}

# az network lb create --resource-group openshift --name OcpRouterLB --public-ip-address routerExternalLB --frontend-ip-name routerFrontend --backend-pool-name routerBackend
resource "azurerm_lb" "router" {
    name                = "OcpRouterLB"
    location            = "${var.datacenter}"
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    sku                 = "standard"

    frontend_ip_configuration {
        name                 = "routerFrontend"
        public_ip_address_id = "${azurerm_public_ip.routerExternalLB.id}"
    }
}
# az network lb probe create --resource-group openshift --lb-name OcpRouterLB --name routerHealthProbe --protocol tcp --port 80
resource "azurerm_lb_probe" "routerHealthProbe" {
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    loadbalancer_id     = "${azurerm_lb.router.id}"
    name                = "routerHealthProbe"
    port                = 80
    protocol            = "Tcp"
}


# az network lb rule create --resource-group openshift --lb-name OcpRouterLB --name routerRule --protocol tcp --frontend-port 80 --backend-port 80 --frontend-ip-name routerFrontend --backend-pool-name routerBackend --probe-name routerHealthProbe --load-distribution SourceIPProtocol
resource "azurerm_lb_backend_address_pool" "routerBackend" {
    resource_group_name = "${azurerm_resource_group.openshift.name}"
    loadbalancer_id     = "${azurerm_lb.router.id}"
    name                = "routerBackend"
}

resource "azurerm_lb_rule" "routerRule" {
    resource_group_name            = "${azurerm_resource_group.openshift.name}"
    loadbalancer_id                = "${azurerm_lb.router.id}"
    name                           = "routerRule"
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "routerFrontend"
    backend_address_pool_id        = "${azurerm_lb_backend_address_pool.routerBackend.id}"
    probe_id                       = "${azurerm_lb_probe.routerHealthProbe.id}"
    load_distribution              = "SourceIPProtocol"
}


# az network lb rule create --resource-group openshift --lb-name OcpRouterLB --name httpsRouterRule --protocol tcp --frontend-port 443 --backend-port 443 --frontend-ip-name routerFrontend --backend-pool-name routerBackend --probe-name routerHealthProbe --load-distribution SourceIPProtocol
resource "azurerm_lb_rule" "httpsRouterRule" {
    resource_group_name            = "${azurerm_resource_group.openshift.name}"
    loadbalancer_id                = "${azurerm_lb.router.id}"
    name                           = "httpsRouterRule"
    protocol                       = "Tcp"
    frontend_port                  = 443
    backend_port                   = 443
    frontend_ip_configuration_name = "routerFrontend"
    backend_address_pool_id        = "${azurerm_lb_backend_address_pool.routerBackend.id}"
    probe_id                       = "${azurerm_lb_probe.routerHealthProbe.id}"
    load_distribution              = "SourceIPProtocol"
}

resource "azurerm_dns_zone" "private" {
  name                = "openshift.local"
  resource_group_name = "${azurerm_resource_group.openshift.name}"
  zone_type           = "Private"
}
