data "azurerm_resource_group" "vm-rg" {
  name = "${var.rg}"
}

data "azurerm_virtual_network" "devopsvnet" {
  name                = "${var.vnet}"
  resource_group_name = "${data.azurerm_resource_group.vm-rg.name}"
  depends_on          = ["data.azurerm_resource_group.vm-rg"]
}

data "azurerm_subnet" "devopssubnet" {
  name                 = "${var.subnet}"
  resource_group_name  = "${data.azurerm_resource_group.vm-rg.name}"
  virtual_network_name = "${data.azurerm_virtual_network.devopsvnet.name}"
}

data "azurerm_key_vault" "devops-kv" {
  name                = "${var.keyvault}"
  resource_group_name = "${data.azurerm_resource_group.vm-rg.name}"
  depends_on          = ["data.azurerm_resource_group.vm-rg"]
}

resource "azurerm_public_ip" "devops-pip" {
  name                    = "${var.hostname}-devops-pip"
  location                = "${data.azurerm_resource_group.vm-rg.location}"
  resource_group_name     = "${data.azurerm_resource_group.vm-rg.name}"
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.hostname}-nic"
  location            = "${data.azurerm_resource_group.vm-rg.location}"
  resource_group_name = "${data.azurerm_resource_group.vm-rg.name}"

  ip_configuration {
    name                          = "devops-ipconfig"
    subnet_id                     = "${data.azurerm_subnet.devopssubnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.static_ip}"
    public_ip_address_id          = "${azurerm_public_ip.devops-pip.id}"
  }
}

data "azurerm_image" "custom" {
  name                = "buildagent-image"
  resource_group_name = "${var.image-rg}"
}

# Put the SSH pub key in Keyvault
resource "azurerm_key_vault_secret" "devops-kv-secret" {
  name         = "clientssh"
  value        = "${var.ssh}"
  key_vault_id = "${data.azurerm_key_vault.devops-kv.id}"
}

resource "azurerm_virtual_machine" "buildagent" {
  name                  = "${var.hostname}"
  location              = "${data.azurerm_resource_group.vm-rg.location}"
  resource_group_name   = "${data.azurerm_resource_group.vm-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "${var.vm_size}"
  depends_on            = ["azurerm_key_vault_secret.devops-kv-secret"]


  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.custom.id}"
  }

  storage_os_disk {
    name              = "${var.hostname}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "buildagent"
    admin_username = "vagrant"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/vagrant/.ssh/authorized_keys"
      key_data = "${var.ssh}"
    }
  }
}

