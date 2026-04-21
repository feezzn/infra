# ============================================================
# AKS Cluster - Production Ready Configuration
# ============================================================

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# ============================================================
# VARIABLES
# ============================================================

variable "environment" {
  type    = string
  default = "production"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "cluster_name" {
  type    = string
  default = "aks-cluster"
}

# ============================================================
# RESOURCE GROUP
# ============================================================

resource "azurerm_resource_group" "aks_rg" {
  name     = "${var.cluster_name}-rg-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# NETWORKING - VNet & Subnets
# ============================================================

resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.cluster_name}-vnet"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = ["10.0.0.0/8"]

  tags = {
    Environment = var.environment
  }
}

# Subnet for AKS nodes
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.1.0.0/16"]
}

# Subnet for Ingress/Application Gateway
resource "azurerm_subnet" "ingress_subnet" {
  name                 = "${var.cluster_name}-ingress-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.2.0.0/16"]
}

# ============================================================
# NETWORK SECURITY GROUP
# ============================================================

resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.cluster_name}-nsg"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "AllowKubeletAPI"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10250"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_subnet_network_security_group_association" "aks_nsg_assoc" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

# ============================================================
# AZURE CONTAINER REGISTRY (ACR)
# ============================================================

resource "azurerm_container_registry" "acr" {
  name                = replace("${var.cluster_name}acr", "-", "")
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = "Standard"
  admin_enabled       = false

  tags = {
    Environment = var.environment
  }
}

# ============================================================
# KEY VAULT (for secrets management)
# ============================================================

resource "azurerm_key_vault" "aks_kv" {
  name                = "${var.cluster_name}-kv-${substr(md5(azurerm_resource_group.aks_rg.id), 0, 8)}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete"
    ]
  }

  tags = {
    Environment = var.environment
  }
}

# ============================================================
# USER MANAGED IDENTITY (for RBAC)
# ============================================================

resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "${var.cluster_name}-identity"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
}

# Role assignment: AKS identity can pull from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope              = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id       = azurerm_user_assigned_identity.aks_identity.principal_id
}

# ============================================================
# AKS CLUSTER - PRODUCTION READY
# ============================================================

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.cluster_name
  kubernetes_version  = "1.28"  # Use stable version

  # ============================================================
  # DEFAULT NODE POOL (with High Availability)
  # ============================================================
  default_node_pool {
    name            = "default"
    node_count      = 3
    vm_size         = "Standard_DS2_v2"
    os_disk_size_gb = 128

    # Spread across availability zones for HA
    zones = ["1", "2", "3"]

    # Network configuration
    vnet_subnet_id = azurerm_subnet.aks_subnet.id

    # Enable cluster autoscaling
    enable_auto_scaling  = true
    min_count            = 3
    max_count            = 10

    # Enable node public IP (optional, can disable for security)
    enable_node_public_ip = false

    tags = {
      Environment = var.environment
    }
  }

  # ============================================================
  # IDENTITY (for RBAC and managed addons)
  # ============================================================
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  # ============================================================
  # NETWORK PROFILE (Security & Network Policies)
  # ============================================================
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"  # Enable network policies
    service_cidr      = "10.10.0.0/16"
    dns_service_ip    = "10.10.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    load_balancer_sku = "standard"
  }

  # ============================================================
  # ADDONS (Monitoring, Policy, Ingress)
  # ============================================================
  addon_profile {
    # Azure Policy for compliance
    azure_policy {
      enabled = true
    }

    # OMS Agent for monitoring/logging
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_workspace.id
    }

    # Application Gateway Ingress Controller (AGIC)
    ingress_application_gateway {
      enabled   = true
      gateway_id = azurerm_application_gateway.aks_appgw.id
    }
  }

  # ============================================================
  # RBAC (Role-Based Access Control - Least Privilege)
  # ============================================================
  role_based_access_control_enabled = true

  # ============================================================
  # API SERVER AUTHORIZED IP RANGES (Security)
  # ============================================================
  # api_server_authorized_ip_ranges = ["0.0.0.0/0"]  # Restrict this in production!

  depends_on = [
    azurerm_role_assignment.aks_acr_pull,
    azurerm_subnet_network_security_group_association.aks_nsg_assoc
  ]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# MONITORING - LOG ANALYTICS WORKSPACE
# ============================================================

resource "azurerm_log_analytics_workspace" "aks_workspace" {
  name                = "${var.cluster_name}-workspace"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"

  tags = {
    Environment = var.environment
  }
}

# ============================================================
# APPLICATION GATEWAY (for AGIC Ingress)
# ============================================================

resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.cluster_name}-appgw-pip"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_application_gateway" "aks_appgw" {
  name                = "${var.cluster_name}-appgw"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.ingress_subnet.id
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  frontend_port {
    name = "appgw-frontend-port-80"
    port = 80
  }

  backend_address_pool {
    name = "appgw-backend-pool"
  }

  backend_http_settings {
    name                  = "appgw-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "appgw-http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "appgw-frontend-port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "appgw-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "appgw-http-listener"
    backend_address_pool_name  = "appgw-backend-pool"
    backend_http_settings_name = "appgw-http-settings"
    priority                   = 1
  }

  tags = {
    Environment = var.environment
  }
}

# ============================================================
# DATA SOURCES
# ============================================================

data "azurerm_client_config" "current" {}

# ============================================================
# OUTPUTS
# ============================================================

output "aks_cluster_id" {
  value       = azurerm_kubernetes_cluster.aks_cluster.id
  description = "AKS Cluster ID"
}

output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks_cluster.name
  description = "AKS Cluster Name"
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive   = true
  description = "Kubeconfig for AKS cluster"
}

output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "ACR Login Server"
}

output "key_vault_id" {
  value       = azurerm_key_vault.aks_kv.id
  description = "Key Vault ID for secrets management"
}
