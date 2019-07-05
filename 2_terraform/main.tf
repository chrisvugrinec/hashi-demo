resource "azurerm_resource_group" "rg" {
  name     = "${var.rg}"
  location = "${var.location}"
}

module "network" {
  source = "./network"
  rg     = "${azurerm_resource_group.rg.name}"
  vnet   = "${var.vnet}"
  subnet = "${var.subnet}"
}

module "keyvault" {
  source = "./keyvault"
  tenant_id  = "${var.TENANT_ID}"
  object_id  = "${var.OBJECT_ID}"
  object_id2 = "${var.OBJECT_ID2}"
  rg         = "${azurerm_resource_group.rg.name}"
  keyvault-name   = "devops-kv-${random_string.random-namespace.result}"
}

module "aks1" {
  source = "./aks"
  aksname = "aksdemo1"
  nodecount = 3
  aksvnet-name = "aks-vnet1"
  akssubnet-name = "aks-subnet1"
  aksvnet = "10.1.0.0/16"
  akssubnet = "10.1.0.0/24" 
  rg = "${azurerm_resource_group.rg.name}"
  random-string = "${random_string.random-namespace.result}"
  client_id     = "${var.CLIENT_ID}"
  client_secret = "${var.CLIENT_SECRET}"
}


module "vm1" {
  source = "./vm"
  static_ip = "10.0.2.5"
  ssh = "${var.SSH}"
  rg = "${azurerm_resource_group.rg.name}"
  hostname = "buildagent1"
  vnet = "${var.vnet}"
  subnet = "${var.subnet}"
  keyvault = "devops-kv-${random_string.random-namespace.result}"
}

module "vm2" {
  source = "./vm"
  static_ip = "10.0.2.6"
  ssh = "${var.SSH}"
  rg = "${azurerm_resource_group.rg.name}"
  hostname = "buildagent2"
  vnet = "${var.vnet}"
  subnet = "${var.subnet}"
  keyvault = "devops-kv-${random_string.random-namespace.result}"
}
