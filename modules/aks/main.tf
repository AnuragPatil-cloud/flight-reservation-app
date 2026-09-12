resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.project_name}-${var.environment}-aks-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = "${var.project_name}-${var.environment}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.project_name}-${var.environment}"

  node_resource_group = "${var.project_name}-${var.environment}-aksnodes"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  default_node_pool {
    name            = "system"
    vm_size         = "Standard_D2ads_v6"
    vnet_subnet_id  = var.subnet_id
    node_count      = 1
    max_pods        = 30
    os_disk_size_gb = 64
    type            = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.30.0.0/16"
    dns_service_ip    = "10.30.0.10"
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  lifecycle {
    ignore_changes = [
      default_node_pool[0].upgrade_settings
    ]
  }

  depends_on = [
    azurerm_role_assignment.network_contributor
  ]

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}
