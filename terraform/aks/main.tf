data "azurerm_resource_group" "vm-rg"{
  name = "${var.rg}"
}

# MgmtHub VNET
resource "azurerm_virtual_network" "aksdemo-mgmthub-vnet" {
  name                = "aksdemo-mgmthub-vnet"
  location            = "${data.azurerm_resource_group.vm-rg.location}"
  resource_group_name = "${data.azurerm_resource_group.vm-rg.name}"
  address_space       = ["11.0.100.0/22"]

  subnet {
    name           = "aksdemo-mgmthub-subnet"
    address_prefix = "11.0.102.0/24"
  }
}

# AKS VNET
resource "azurerm_virtual_network" "aksdemo-aks-vnet" {
  name                = "aksdemo-aks-vnet"
  location            = "${data.azurerm_resource_group.vm-rg.location}"
  resource_group_name = "${data.azurerm_resource_group.vm-rg.name}"
  address_space       = ["10.1.0.0/16"]
}

# AKS SUBNET
resource "azurerm_subnet" "aksdemo-aks-subnet" {
  name                = "aksdemo-aks-subnet"
  resource_group_name = "${data.azurerm_resource_group.vm-rg.name}"
  # commented out, is deprecated should use: azurerm_subnet_network_security_group_association 
  #network_security_group_id = "${azurerm_network_security_group.aksdemo-aks-nsg.id}"
  address_prefix       = "10.1.0.0/24"
  virtual_network_name = "${azurerm_virtual_network.aksdemo-aks-vnet.name}"
}

# AKS NSG
resource azurerm_network_security_group "aksdemo-aks-nsg" {
  name                = "aksdemo-aks-nsg"
  location            = "${data.azurerm_resource_group.vm-rg.location}"
  resource_group_name = "${data.azurerm_resource_group.vm-rg.name}"
}

output "randomstring_message" {
  value = "${var.random-string}"
}

output "kube_subnet_id" {
  value = "${azurerm_subnet.aksdemo-aks-subnet.id}"
}


# Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aksdemo-aks" {
  name                = "aksdemo-${var.random-string}"
  location            = "${data.azurerm_resource_group.vm-rg.location}"
  resource_group_name = "${data.azurerm_resource_group.vm-rg.name}"
  dns_prefix          = "aksagent-aks-${var.random-string}"

  agent_pool_profile {
    name            = "aksdemotd"
    count           = 1
    vm_size         = "Standard_D2_v3"
    os_type         = "Linux"
    os_disk_size_gb = 30
    vnet_subnet_id  = "${azurerm_subnet.aksdemo-aks-subnet.id}"
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }
}


# Azure Container Registry (ACR)
resource "azurerm_container_registry" "aksdemo-acr" {
  name                = "aksdemoacr${var.random-string}"
  location            = "${data.azurerm_resource_group.vm-rg.location}"
  resource_group_name = "${data.azurerm_resource_group.vm-rg.name}"
  admin_enabled       = true
  sku                 = "Standard"
}

# MgmtHub VNET Peering to AKS
resource "azurerm_virtual_network_peering" "aksdemo-mgmthub-peering" {
  name                         = "mgmthub-to-aks"
  resource_group_name          = "${data.azurerm_resource_group.vm-rg.name}"
  virtual_network_name         = "${azurerm_virtual_network.aksdemo-mgmthub-vnet.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.aksdemo-aks-vnet.id}"
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

# AKS VNET Peering to ManagementHub
resource "azurerm_virtual_network_peering" "aksdemo-aks-peering" {
  name                         = "aks-to-mgmthub"
  resource_group_name          = "${data.azurerm_resource_group.vm-rg.name}"
  virtual_network_name         = "${azurerm_virtual_network.aksdemo-aks-vnet.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.aksdemo-mgmthub-vnet.id}"
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

