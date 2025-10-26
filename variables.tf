variable "expressroute_circuit_name" {
  description = "Name of the ExpressRoute circuit. If null, will be auto-generated."
  type        = string
  default     = null
}

variable "naming_prefix" {
  description = "Prefix for ExpressRoute naming"
  type        = string
  default     = "expressroute"
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, test)"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "service_provider_name" {
  description = "Name of the ExpressRoute service provider"
  type        = string
}

variable "peering_location" {
  description = "Location of the peering"
  type        = string
}

variable "bandwidth_in_mbps" {
  description = "Bandwidth of the circuit in Mbps"
  type        = number
  validation {
    condition     = contains([50, 100, 200, 500, 1000, 2000, 5000, 10000], var.bandwidth_in_mbps)
    error_message = "Bandwidth must be one of: 50, 100, 200, 500, 1000, 2000, 5000, 10000 Mbps."
  }
}

variable "sku_tier" {
  description = "SKU tier of the ExpressRoute circuit"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Local", "Standard", "Premium"], var.sku_tier)
    error_message = "SKU tier must be Local, Standard, or Premium."
  }
}

variable "sku_family" {
  description = "SKU family of the ExpressRoute circuit"
  type        = string
  default     = "MeteredData"
  validation {
    condition     = contains(["MeteredData", "UnlimitedData"], var.sku_family)
    error_message = "SKU family must be MeteredData or UnlimitedData."
  }
}

variable "allow_classic_operations" {
  description = "Allow classic operations"
  type        = bool
  default     = false
}

variable "express_route_port_id" {
  description = "ExpressRoute port ID for Direct circuits"
  type        = string
  default     = null
}

variable "circuit_authorizations" {
  description = "Circuit authorization configurations"
  type = map(object({
    name = string
  }))
  default = {}
}

variable "enable_private_peering" {
  description = "Enable private peering"
  type        = bool
  default     = true
}

variable "private_peering" {
  description = "Private peering configuration"
  type = object({
    primary_peer_address_prefix   = string
    secondary_peer_address_prefix = string
    vlan_id                       = number
    peer_asn                      = optional(number, 65000)
    ipv6 = optional(object({
      primary_peer_address_prefix   = string
      secondary_peer_address_prefix = string
      microsoft_peering = object({
        advertised_public_prefixes = list(string)
        customer_asn               = number
        routing_registry_name      = string
      })
    }))
    route_filter_id = optional(string)
  })
  default = null
}

variable "enable_microsoft_peering" {
  description = "Enable Microsoft peering"
  type        = bool
  default     = false
}

variable "microsoft_peering" {
  description = "Microsoft peering configuration"
  type = object({
    primary_peer_address_prefix   = string
    secondary_peer_address_prefix = string
    vlan_id                       = number
    peer_asn                      = optional(number, 65000)
    advertised_public_prefixes    = list(string)
    customer_asn                  = number
    routing_registry_name         = string
    ipv6 = optional(object({
      primary_peer_address_prefix   = string
      secondary_peer_address_prefix = string
      microsoft_peering = object({
        advertised_public_prefixes = list(string)
        customer_asn               = number
        routing_registry_name      = string
      })
    }))
  })
  default = null
}

variable "expressroute_gateways" {
  description = "ExpressRoute gateway configurations"
  type = map(object({
    name = optional(string)
    sku  = string
    ip_configurations = list(object({
      name                          = string
      public_ip_address_id          = string
      private_ip_address_allocation = string
      subnet_id                     = string
    }))
    active_active = bool
    vpn_client_configuration = optional(object({
      address_space = list(string)
      root_certificate = object({
        name             = string
        public_cert_data = string
      })
      revoked_certificate = object({
        name       = string
        thumbprint = string
      })
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "circuit_connections" {
  description = "Circuit connection configurations"
  type = map(object({
    name                     = string
    peering_id               = string
    address_prefix_ipv4      = string
    authorization_key        = optional(string)
    routing_weight           = optional(number, 0)
    enable_internet_security = optional(bool, true)
  }))
  default = {}
}

variable "route_filters" {
  description = "Route filter configurations"
  type = map(object({
    name = string
    rules = list(object({
      name        = string
      access      = string
      rule_type   = string
      communities = list(string)
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "gateway_subnet_nsgs" {
  description = "NSG configurations for gateway subnets"
  type = map(object({
    name = string
    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "diagnostic_settings" {
  description = "Diagnostic settings configurations"
  type = map(object({
    name                       = string
    log_analytics_workspace_id = string
    logs = list(object({
      category = string
    }))
    metrics = list(object({
      category = string
      enabled  = bool
    }))
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_policy_assignments" {
  description = "Enable Azure Policy assignments"
  type        = bool
  default     = true
}

variable "enable_custom_policies" {
  description = "Enable custom policy definitions"
  type        = bool
  default     = false
}

variable "minimum_bandwidth_mbps" {
  description = "Minimum required bandwidth in Mbps"
  type        = number
  default     = 1000
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings"
  type        = string
  default     = null
}