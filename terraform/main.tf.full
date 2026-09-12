module "vm_network" {
  source = "./modules/network"

  location     = var.vm_location
  project_name = "${var.project_name}-vm"
  environment  = var.environment

  address_space = ["10.10.0.0/16"]

  subnets = {
    ci = {
      name             = "snet-ci"
      address_prefixes = ["10.10.1.0/24"]
    }

    monitoring = {
      name             = "snet-monitoring"
      address_prefixes = ["10.10.2.0/24"]
    }
  }
}

module "aks_network" {
  source = "./modules/network"

  location     = var.aks_location
  project_name = "${var.project_name}-aks"
  environment  = var.environment

  address_space = ["10.20.0.0/16"]

  subnets = {
    aks = {
      name             = "snet-aks"
      address_prefixes = ["10.20.1.0/24"]
    }
  }
}

module "vm" {
  source = "./modules/vm"

  location            = var.vm_location
  resource_group_name = module.vm_network.resource_group_name

  project_name = var.project_name
  environment  = var.environment

  admin_username      = var.admin_username
  ssh_public_key_path = var.ssh_public_key_path

  vm_size = var.vm_size

  subnets = {
    ci         = module.vm_network.subnet_ids["ci"]
    monitoring = module.vm_network.subnet_ids["monitoring"]
  }
}

module "aks" {
  source = "./modules/aks"

  location            = var.aks_location
  resource_group_name = module.aks_network.resource_group_name
  subnet_id           = module.aks_network.subnet_ids["aks"]

  project_name = var.project_name
  environment  = var.environment

  admin_username      = var.admin_username
  ssh_public_key_path = var.ssh_public_key_path

  node_vm_size = var.aks_node_vm_size
}

module "storage" {
  source = "./modules/storage"

  location            = var.aks_location
  resource_group_name = module.aks_network.resource_group_name

  project_name = var.project_name
  environment  = var.environment
}

module "sns" {
  source = "./modules/sns"

  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = module.vm_network.resource_group_name
}

module "budgets" {
  source = "./modules/budgets"

  subscription_id = var.subscription_id
  project_name    = var.project_name
  environment     = var.environment

  vm_resource_group_id  = module.vm_network.resource_group_id
  aks_resource_group_id = module.aks_network.resource_group_id
}
