provider "azurerm" {
  features {}
}

locals {
  name        = "opsstation"
  environment = "test"
}

module "resource_group_1" {
  source      = "git::https://github.com/opsstation/terraform-azure-resource-group.git?ref=v1.0.0"
  name        = local.name
  environment = local.environment
  location    = "West Europe"
}


module "resource_group_2" {
  source      = "git::https://github.com/opsstation/terraform-azure-resource-group.git?ref=v1.0.0"
  name        = "test"
  environment = local.environment
  location    = "East US"
}



#Vnet
module "vnet" {
  source              = "git::https://github.com/opsstation/terraform-azure-vnet.git?ref=v1.0.0"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group_1.resource_group_name
  location            = module.resource_group_1.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

#Vnet
module "vnet_remote" {
  source              = "git::https://github.com/opsstation/terraform-azure-vnet.git?ref=v1.0.0"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group_2.resource_group_name
  location            = module.resource_group_2.resource_group_location
  address_spaces      = ["20.0.0.0/16"]
}

module "vnet_peering" {
  source                = "../.."
  enabled_peering       = true
  resource_group_1_name = module.resource_group_1.resource_group_name
  resource_group_2_name = module.resource_group_2.resource_group_name
  different_rg          = true
  vnet_1_name           = module.vnet.vnet_name[0]
  vnet_1_id             = module.vnet.vnet_id[0]
  vnet_2_name           = module.vnet_remote.vnet_name[0]
  vnet_2_id             = module.vnet_remote.vnet_id[0]
}
