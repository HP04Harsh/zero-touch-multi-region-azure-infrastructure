resource "azurerm_virtual_network" "vnet-india" {
  name                = "$vnet-india"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-india.location 
  resource_group_name = azurerm_resource_group.rg-india.name
}   

resource "azurerm_subnet" "subnet-india" {
  name                 = "subnet-india"
  resource_group_name  = azurerm_resource_group.rg-india.name
  virtual_network_name = azurerm_virtual_network.vnet-india.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip-india" {
  name                = "pip-india"
  location            = azurerm_resource_group.rg-india.location
  resource_group_name = azurerm_resource_group.rg-india.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "nsg" {
  name = "nsg-india"
  location = "${azurerm_resource_group.rg-india.location}"
  resource_group_name = "${azurerm_resource_group.rg-india.name}"
  
  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  } 
}