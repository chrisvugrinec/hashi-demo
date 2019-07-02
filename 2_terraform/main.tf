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
  keyvault   = "devops-kv-${random_string.random-namespace.result}"
}

module "aks" {
  source = "./aks"
  rg = "${azurerm_resource_group.rg.name}"
  random-string = "${random_string.random-namespace.result}"
  client_id     = "${var.CLIENT_ID}"
  client_secret = "${var.CLIENT_SECRET}"
} 

module "vm1" {
  source = "./vm1"
  ssh = "${var.SSH}"
  rg = "${azurerm_resource_group.rg.name}"
  vnet = "${var.vnet}"
  subnet = "${var.subnet}"
  keyvault = "devops-kv-${random_string.random-namespace.result}"
}
