
resource "azurerm_resource_group" "rg_india" {
  name     = "india-rg"
  location = "Central India"
}


resource "azurerm_resource_group" "rg_us" {
  name     = "us-rg"
  location = "East US"
}

module "network_india" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.rg_india.name
  location            = azurerm_resource_group.rg_india.location
  prefix              = "india"
}

module "vm_india" {
  source              = "./modules/compute"
  resource_group_name = azurerm_resource_group.rg_india.name
  location            = azurerm_resource_group.rg_india.location
  subnet_id           = module.network_india.subnet_id
  suffix              = "india"
  
  admin_username      = var.admin_username
  admin_password      = var.admin_password

}



module "network_us" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.rg_us.name
  location            = azurerm_resource_group.rg_us.location
  prefix              = "us"
}

module "vm_us" {
  source              = "./modules/compute"
  resource_group_name = azurerm_resource_group.rg_us.name
  location            = azurerm_resource_group.rg_us.location
  subnet_id           = module.network_us.subnet_id
  suffix              = "us"
  
  admin_username      = var.admin_username
  admin_password      = var.admin_password

}



module "front_door" {
  source              = "./modules/front_door"
  # We host the Front Door config in the India RG (it's a global service)
  resource_group_name = azurerm_resource_group.rg_india.name
  
  # Links the two regional VMs to the global entry point
  india_vm_ip         = module.vm_india.public_ip
  us_vm_ip            = module.vm_us.public_ip
}