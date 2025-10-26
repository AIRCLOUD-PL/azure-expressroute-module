# ExpressRoute Module - Enterprise Connectivity
# Creates Azure ExpressRoute circuits with enterprise-grade security and compliance



# ExpressRoute Circuit
resource "azurerm_express_route_circuit" "main" {
  name                  = local.expressroute_circuit_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  service_provider_name = var.service_provider_name
  peering_location      = var.peering_location
  bandwidth_in_mbps     = var.bandwidth_in_mbps

  sku {
    tier   = var.sku_tier
    family = var.sku_family
  }

  # Allow classic operations for legacy support
  allow_classic_operations = var.allow_classic_operations

  # ExpressRoute Direct port configuration (if using Direct ports)
  express_route_port_id = var.express_route_port_id
  bandwidth_in_gbps     = var.express_route_port_id != null ? (var.bandwidth_in_mbps / 1000) : null

  tags = local.tags
}

# ExpressRoute Circuit Authorizations
resource "azurerm_express_route_circuit_authorization" "authorizations" {
  for_each = var.circuit_authorizations

  name                       = each.value.name
  express_route_circuit_name = azurerm_express_route_circuit.main.name
  resource_group_name        = var.resource_group_name
}

# Private Peering
resource "azurerm_express_route_circuit_peering" "private_peering" {
  count = var.enable_private_peering ? 1 : 0

  peering_type                  = "AzurePrivatePeering"
  express_route_circuit_name    = azurerm_express_route_circuit.main.name
  resource_group_name           = var.resource_group_name
  primary_peer_address_prefix   = var.private_peering.primary_peer_address_prefix
  secondary_peer_address_prefix = var.private_peering.secondary_peer_address_prefix
  vlan_id                       = var.private_peering.vlan_id

  # Microsoft peering settings
  peer_asn = var.private_peering.peer_asn

  # IPv6 support
  dynamic "ipv6" {
    for_each = var.private_peering.ipv6 != null ? [var.private_peering.ipv6] : []
    content {
      primary_peer_address_prefix   = ipv6.value.primary_peer_address_prefix
      secondary_peer_address_prefix = ipv6.value.secondary_peer_address_prefix
      microsoft_peering {
        advertised_public_prefixes = ipv6.value.microsoft_peering.advertised_public_prefixes
        customer_asn               = ipv6.value.microsoft_peering.customer_asn
        routing_registry_name      = ipv6.value.microsoft_peering.routing_registry_name
      }
    }
  }

  # Route filter for security
  route_filter_id = var.private_peering.route_filter_id
}

# Microsoft Peering
resource "azurerm_express_route_circuit_peering" "microsoft_peering" {
  count = var.enable_microsoft_peering ? 1 : 0

  peering_type                  = "MicrosoftPeering"
  express_route_circuit_name    = azurerm_express_route_circuit.main.name
  resource_group_name           = var.resource_group_name
  primary_peer_address_prefix   = var.microsoft_peering.primary_peer_address_prefix
  secondary_peer_address_prefix = var.microsoft_peering.secondary_peer_address_prefix
  vlan_id                       = var.microsoft_peering.vlan_id

  peer_asn = var.microsoft_peering.peer_asn

  # IPv6 support
  dynamic "ipv6" {
    for_each = var.microsoft_peering.ipv6 != null ? [var.microsoft_peering.ipv6] : []
    content {
      primary_peer_address_prefix   = ipv6.value.primary_peer_address_prefix
      secondary_peer_address_prefix = ipv6.value.secondary_peer_address_prefix
      microsoft_peering {
        advertised_public_prefixes = ipv6.value.microsoft_peering.advertised_public_prefixes
        customer_asn               = ipv6.value.microsoft_peering.customer_asn
        routing_registry_name      = ipv6.value.microsoft_peering.routing_registry_name
      }
    }
  }
}

# ExpressRoute Gateway
resource "azurerm_virtual_network_gateway" "expressroute_gateway" {
  for_each = var.expressroute_gateways

  name                = each.value.name != null ? each.value.name : "vgw-${var.naming_prefix}-${var.environment}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = "ExpressRoute"
  vpn_type = "RouteBased"

  sku = each.value.sku

  # IP configuration
  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations
    content {
      name                          = ip_configuration.value.name
      public_ip_address_id          = ip_configuration.value.public_ip_address_id
      private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation
      subnet_id                     = ip_configuration.value.subnet_id
    }
  }

  # Active-active configuration
  active_active = each.value.active_active

  # ExpressRoute circuit connection
  dynamic "vpn_client_configuration" {
    for_each = each.value.vpn_client_configuration != null ? [each.value.vpn_client_configuration] : []
    content {
      address_space = vpn_client_configuration.value.address_space
      root_certificate {
        name             = vpn_client_configuration.value.root_certificate.name
        public_cert_data = vpn_client_configuration.value.root_certificate.public_cert_data
      }
      revoked_certificate {
        name       = vpn_client_configuration.value.revoked_certificate.name
        thumbprint = vpn_client_configuration.value.revoked_certificate.thumbprint
      }
    }
  }

  tags = merge(local.tags, each.value.tags)
}

# ExpressRoute Circuit Connections
resource "azurerm_express_route_circuit_connection" "connections" {
  for_each = var.circuit_connections

  name                = each.value.name
  peering_id          = each.value.peering_id
  peer_peering_id     = each.value.peering_id # For circuit-to-circuit connections
  address_prefix_ipv4 = each.value.address_prefix_ipv4

  # Optional attributes
  authorization_key = each.value.authorization_key
}

# Route Filters for security
resource "azurerm_route_filter" "route_filters" {
  for_each = var.route_filters

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location

  dynamic "rule" {
    for_each = each.value.rules
    content {
      name        = rule.value.name
      access      = rule.value.access
      rule_type   = rule.value.rule_type
      communities = rule.value.communities
    }
  }

  tags = merge(local.tags, each.value.tags)
}

# Network Security Groups for ExpressRoute Gateway subnets
resource "azurerm_network_security_group" "gateway_subnets" {
  for_each = var.gateway_subnet_nsgs

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = merge(local.tags, each.value.tags)
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "expressroute_diagnostics" {
  for_each = var.diagnostic_settings

  name                       = each.value.name
  target_resource_id         = azurerm_express_route_circuit.main.id
  log_analytics_workspace_id = each.value.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = each.value.logs
    content {
      category = enabled_log.value.category
    }
  }

  dynamic "metric" {
    for_each = each.value.metrics
    content {
      category = metric.value.category
      enabled  = metric.value.enabled
    }
  }
}

# Local values
locals {
  expressroute_circuit_name = var.expressroute_circuit_name != null ? var.expressroute_circuit_name : "erc-${var.naming_prefix}-${var.environment}"

  tags = merge(
    var.tags,
    {
      Module      = "expressroute"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}