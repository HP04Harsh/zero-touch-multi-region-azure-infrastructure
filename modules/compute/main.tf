resource "azurerm_network_interface" "nic-india" {
  name                = var.project-name
  location            = azurerm_resource_group.rg-india.location
  resource_group_name = azurerm_resource_group.rg-india.name

  ip_configuration {
    name                          = "${var.project-name}-ipconfig-india"
    subnet_id                     = module.networking.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}