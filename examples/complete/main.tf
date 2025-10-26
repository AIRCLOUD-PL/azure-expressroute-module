terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network for ExpressRoute Gateway
resource "azurerm_virtual_network" "example" {
  name                = "vnet-expressroute-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Gateway Subnet
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/27"]
}

# Public IP for ExpressRoute Gateway
resource "azurerm_public_ip" "gateway" {
  name                = "pip-expressroute-gateway"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Log Analytics Workspace for diagnostics
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-expressroute-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "expressroute" {
  source = "../../"

  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  environment           = var.environment
  service_provider_name = var.service_provider_name
  peering_location      = var.peering_location
  bandwidth_in_mbps     = var.bandwidth_in_mbps

  # Premium SKU for enterprise features
  sku_tier   = "Premium"
  sku_family = "UnlimitedData"

  # Private Peering Configuration
  enable_private_peering = true
  private_peering = {
    primary_peer_address_prefix   = "192.168.1.0/30"
    secondary_peer_address_prefix = "192.168.1.4/30"
    vlan_id                       = 100
    peer_asn                      = 65000
    route_filter_id               = azurerm_route_filter.example.id
  }

  # Microsoft Peering for Office 365 and Azure services
  enable_microsoft_peering = true
  microsoft_peering = {
    primary_peer_address_prefix   = "192.168.2.0/30"
    secondary_peer_address_prefix = "192.168.2.4/30"
    vlan_id                       = 200
    peer_asn                      = 65000
    advertised_public_prefixes    = ["203.0.113.0/24"]
    customer_asn                  = 65001
    routing_registry_name         = "ARIN"
  }

  # Circuit Authorizations for connecting VNets
  circuit_authorizations = {
    "vnet1" = {
      name = "vnet1-authorization"
    }
    "vnet2" = {
      name = "vnet2-authorization"
    }
  }

  # ExpressRoute Gateway for VNet connectivity
  expressroute_gateways = {
    "primary" = {
      name = "erg-expressroute-primary"
      sku  = "UltraPerformance"
      ip_configurations = [
        {
          name                          = "ipconfig1"
          public_ip_address_id          = azurerm_public_ip.gateway.id
          private_ip_address_allocation = "Dynamic"
          subnet_id                     = azurerm_subnet.gateway.id
        }
      ]
      active_active = true
      tags = {
        "Zone" = "Primary"
      }
    }
  }

  # Circuit Connections
  circuit_connections = {
    "vnet-connection" = {
      name                = "vnet-to-expressroute"
      peering_id          = "AzurePrivatePeering" # This would be the actual peering ID
      address_prefix_ipv4 = "192.168.3.0/30"
      authorization_key   = "sample-auth-key"
    }
  }

  # Route Filters for security
  route_filters = {
    "security-filter" = {
      name = "rf-expressroute-security"
      rules = [
        {
          name        = "allow-azure-services"
          access      = "Allow"
          rule_type   = "Community"
          communities = ["12076:52005", "12076:52006"] # Azure Public and Private services
        }
      ]
      tags = {
        "Purpose" = "Security"
      }
    }
  }

  # Gateway Subnet NSG
  gateway_subnet_nsgs = {
    "gateway-nsg" = {
      name = "nsg-gateway-subnet"
      security_rules = [
        {
          name                       = "Allow_ExpressRoute"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "ExpressRoute"
          destination_address_prefix = "*"
        }
      ]
      tags = {
        "Purpose" = "GatewaySecurity"
      }
    }
  }

  # Diagnostic Settings
  diagnostic_settings = {
    "log-analytics" = {
      name                       = "expressroute-diagnostics"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      logs = [
        {
          category = "ExpressRouteCircuitArpTable"
        },
        {
          category = "ExpressRouteCircuitRouteTable"
        },
        {
          category = "ExpressRouteCircuitRouteTableSummary"
        }
      ]
      metrics = [
        {
          category = "AllMetrics"
          enabled  = true
        }
      ]
    }
  }

  # Azure Policy Integration
  enable_policy_assignments  = true
  enable_custom_policies     = true
  minimum_bandwidth_mbps     = 1000
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  # Tags
  tags = {
    Environment = var.environment
    Project     = "expressroute-complete-example"
    Owner       = "Network Team"
    CostCenter  = "NET-001"
  }
}

# Route Filter Resource
resource "azurerm_route_filter" "example" {
  name                = "rf-expressroute-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  rule {
    name        = "allow-azure-services"
    access      = "Allow"
    rule_type   = "Community"
    communities = ["12076:52005", "12076:52006"]
  }

  tags = {
    Environment = var.environment
  }
}