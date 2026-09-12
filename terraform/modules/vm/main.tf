resource "azurerm_public_ip" "this" {
  for_each = var.subnets

  name                = "${var.project_name}-${each.key}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "this" {
  for_each = var.subnets

  name                = "${var.project_name}-${each.key}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  for_each = var.subnets

  name                = "${var.project_name}-${each.key}-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size

  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.this[each.key].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
