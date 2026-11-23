<p align="center">
  <a href="https://aircloud.com.pl"><img src=".github/assets/banner.png" alt="AIRCLOUD: DevOps, cloud and AI engineering" width="100%"></a>
</p>

# azure-expressroute-module

**Azure ExpressRoute Terraform module — parameterised, azurerm 4.x, CI-validated.**

[![CI](https://github.com/AIRCLOUD-PL/azure-expressroute-module/actions/workflows/ci.yml/badge.svg)](https://github.com/AIRCLOUD-PL/azure-expressroute-module/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/AIRCLOUD-PL/azure-expressroute-module?sort=semver)](https://github.com/AIRCLOUD-PL/azure-expressroute-module/releases)

This Terraform module creates Azure ExpressRoute circuits with enterprise-grade security, high availability, and comprehensive connectivity options for hybrid cloud architectures.

## Features

- **ExpressRoute Circuits**: Premium circuits with configurable bandwidth and service providers
- **Private Peering**: Secure connectivity to Azure VNets with route filtering
- **Microsoft Peering**: Access to Microsoft services (Office 365, Azure PaaS)
- **ExpressRoute Gateways**: High-performance VNet gateways with active-active configuration
- **Circuit Authorizations**: Secure authorization keys for VNet connections
- **Route Filters**: Security controls for traffic filtering and compliance
- **Network Security Groups**: Gateway subnet protection
- **Diagnostic Settings**: Comprehensive monitoring and logging
- **Azure Policy Integration**: Compliance and governance policies
- **High Availability**: Redundant peering and gateway configurations

## Usage

Pin the module to a release tag:

```hcl
module "expressroute" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-expressroute-module.git?ref=v1.0.0"

  # required inputs
  bandwidth_in_mbps     = 0
  environment           = "..."
  location              = "..."
  peering_location      = "..."
  resource_group_name   = "..."
  service_provider_name = "..."
}
```

All inputs and outputs are listed in the generated reference below ([Inputs](#inputs), [Outputs](#outputs)). Worked examples live in [`examples/`](examples/).

### Basic Example - Private Peering

```hcl
module "expressroute" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-expressroute-module.git?ref=v1.0.0"

  resource_group_name   = "rg-expressroute"
  location             = "westeurope"
  environment          = "prod"
  service_provider_name = "Equinix"
  peering_location     = "Amsterdam"
  bandwidth_in_mbps    = 1000

  # Premium SKU for enterprise features
  sku_tier   = "Premium"
  sku_family = "UnlimitedData"

  # Private peering for VNet connectivity
  enable_private_peering = true
  private_peering = {
    primary_peer_address_prefix   = "192.168.1.0/30"
    secondary_peer_address_prefix = "192.168.1.4/30"
    vlan_id                       = 100
    peer_asn                      = 65000
  }

  tags = {
    Environment = "prod"
    Project     = "hybrid-connectivity"
  }
}
```

### Complete Example - Full Enterprise Setup

```hcl
module "expressroute" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-expressroute-module.git?ref=v1.0.0"

  resource_group_name   = "rg-expressroute"
  location             = "westeurope"
  environment          = "prod"
  service_provider_name = "Equinix"
  peering_location     = "Amsterdam"
  bandwidth_in_mbps    = 10000

  sku_tier   = "Premium"
  sku_family = "UnlimitedData"

  # Private Peering with route filtering
  enable_private_peering = true
  private_peering = {
    primary_peer_address_prefix   = "192.168.1.0/30"
    secondary_peer_address_prefix = "192.168.1.4/30"
    vlan_id                       = 100
    peer_asn                      = 65000
    route_filter_id               = azurerm_route_filter.security.id
  }

  # Microsoft Peering for Office 365
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

  # Circuit authorizations for multiple VNets
  circuit_authorizations = {
    "prod-vnet" = {
      name = "prod-vnet-authorization"
    }
    "dr-vnet" = {
      name = "dr-vnet-authorization"
    }
  }

  # ExpressRoute Gateway
  expressroute_gateways = {
    "primary" = {
      sku = "UltraPerformance"
      ip_configurations = [{
        name                          = "ipconfig1"
        public_ip_address_id          = azurerm_public_ip.gateway.id
        private_ip_address_allocation = "Dynamic"
        subnet_id                     = azurerm_subnet.gateway.id
      }]
      active_active = true
    }
  }

  # Circuit connections
  circuit_connections = {
    "primary-connection" = {
      name                = "primary-vnet-connection"
      peering_id          = azurerm_express_route_circuit_peering.private_peering.id
      address_prefix_ipv4 = "192.168.3.0/30"
      authorization_key   = azurerm_express_route_circuit_authorization.auth[0].authorization_key
    }
  }

  # Route filters for security
  route_filters = {
    "security" = {
      rules = [{
        name        = "allow-azure-services"
        access      = "Allow"
        rule_type   = "Community"
        communities = ["12076:52005", "12076:52006"]
      }]
    }
  }

  # Diagnostic settings
  diagnostic_settings = {
    "monitoring" = {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
      logs = [
        { category = "ExpressRouteCircuitArpTable" },
        { category = "ExpressRouteCircuitRouteTable" }
      ]
      metrics = [{ category = "AllMetrics", enabled = true }]
    }
  }

  # Azure Policy integration
  enable_policy_assignments = true
  minimum_bandwidth_mbps   = 1000

  tags = {
    Environment = "prod"
    Project     = "enterprise-connectivity"
    Owner       = "Network Team"
  }
}
```

## Security Features

- **Route Filtering**: Control traffic flow with BGP community filters
- **Network Security Groups**: Gateway subnet protection
- **Private Peering**: Encrypted connectivity to Azure VNets
- **Authorization Keys**: Secure VNet-to-circuit connections
- **Azure Policy**: Compliance enforcement for bandwidth and security
- **Diagnostic Logging**: Comprehensive monitoring and audit trails

## High Availability

- **Redundant Peering**: Primary and secondary peer addresses
- **Active-Active Gateways**: Load balancing and failover
- **Premium SKU**: Global reach and higher SLA
- **Circuit Authorizations**: Multiple VNet connections
- **Route Filters**: Consistent security across peerings

## Monitoring and Compliance

The module includes comprehensive diagnostic settings for:
- Circuit ARP tables and route tables
- Peering status and performance metrics
- Gateway connectivity and throughput
- Security events and compliance logs

## Testing

```bash
cd test
go test -v ./test/ -timeout 30m
```

Tests cover:
- Basic circuit creation with private peering
- Microsoft peering configuration
- Circuit authorization setup
- Premium SKU validation
- Naming convention compliance

## Cost Optimization

- **Metered vs Unlimited**: Choose appropriate billing model
- **Bandwidth Planning**: Right-size circuits for workload requirements
- **Route Filters**: Minimize advertised routes for efficiency
- **Peering Selection**: Use private peering for Azure connectivity

## Contributing

1. Follow established patterns for variable naming and resource configuration
2. Include comprehensive test coverage for new peering types or features
3. Update documentation for any new connectivity options
4. Ensure compliance with enterprise security and networking standards

## Reference

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_express_route_circuit.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit) | resource |
| [azurerm_express_route_circuit_authorization.authorizations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit_authorization) | resource |
| [azurerm_express_route_circuit_connection.connections](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit_connection) | resource |
| [azurerm_express_route_circuit_peering.microsoft_peering](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit_peering) | resource |
| [azurerm_express_route_circuit_peering.private_peering](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit_peering) | resource |
| [azurerm_monitor_diagnostic_setting.expressroute_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_network_security_group.gateway_subnets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_policy_definition.expressroute_bandwidth_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_route_filter.route_filters](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_filter) | resource |
| [azurerm_subscription_policy_assignment.expressroute_bandwidth_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_subscription_policy_assignment.expressroute_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_subscription_policy_assignment.expressroute_encryption](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_subscription_policy_assignment.expressroute_premium_sku](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_subscription_policy_assignment.expressroute_private_peering](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_subscription_policy_assignment.expressroute_route_filters](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_virtual_network_gateway.expressroute_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_classic_operations"></a> [allow\_classic\_operations](#input\_allow\_classic\_operations) | Allow classic operations | `bool` | `false` | no |
| <a name="input_bandwidth_in_mbps"></a> [bandwidth\_in\_mbps](#input\_bandwidth\_in\_mbps) | Bandwidth of the circuit in Mbps | `number` | n/a | yes |
| <a name="input_circuit_authorizations"></a> [circuit\_authorizations](#input\_circuit\_authorizations) | Circuit authorization configurations | <pre>map(object({<br/>    name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_circuit_connections"></a> [circuit\_connections](#input\_circuit\_connections) | Circuit connection configurations | <pre>map(object({<br/>    name                     = string<br/>    peering_id               = string<br/>    address_prefix_ipv4      = string<br/>    authorization_key        = optional(string)<br/>    routing_weight           = optional(number, 0)<br/>    enable_internet_security = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings configurations | <pre>map(object({<br/>    name                       = string<br/>    log_analytics_workspace_id = string<br/>    logs = list(object({<br/>      category = string<br/>    }))<br/>    metrics = list(object({<br/>      category = string<br/>      enabled  = bool<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_custom_policies"></a> [enable\_custom\_policies](#input\_enable\_custom\_policies) | Enable custom policy definitions | `bool` | `false` | no |
| <a name="input_enable_microsoft_peering"></a> [enable\_microsoft\_peering](#input\_enable\_microsoft\_peering) | Enable Microsoft peering | `bool` | `false` | no |
| <a name="input_enable_policy_assignments"></a> [enable\_policy\_assignments](#input\_enable\_policy\_assignments) | Enable Azure Policy assignments | `bool` | `true` | no |
| <a name="input_enable_private_peering"></a> [enable\_private\_peering](#input\_enable\_private\_peering) | Enable private peering | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., prod, dev, test) | `string` | n/a | yes |
| <a name="input_express_route_port_id"></a> [express\_route\_port\_id](#input\_express\_route\_port\_id) | ExpressRoute port ID for Direct circuits | `string` | `null` | no |
| <a name="input_expressroute_circuit_name"></a> [expressroute\_circuit\_name](#input\_expressroute\_circuit\_name) | Name of the ExpressRoute circuit. If null, will be auto-generated. | `string` | `null` | no |
| <a name="input_expressroute_gateways"></a> [expressroute\_gateways](#input\_expressroute\_gateways) | ExpressRoute gateway configurations | <pre>map(object({<br/>    name = optional(string)<br/>    sku  = string<br/>    ip_configurations = list(object({<br/>      name                          = string<br/>      public_ip_address_id          = string<br/>      private_ip_address_allocation = string<br/>      subnet_id                     = string<br/>    }))<br/>    active_active = bool<br/>    vpn_client_configuration = optional(object({<br/>      address_space = list(string)<br/>      root_certificate = object({<br/>        name             = string<br/>        public_cert_data = string<br/>      })<br/>      revoked_certificate = object({<br/>        name       = string<br/>        thumbprint = string<br/>      })<br/>    }))<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_gateway_subnet_nsgs"></a> [gateway\_subnet\_nsgs](#input\_gateway\_subnet\_nsgs) | NSG configurations for gateway subnets | <pre>map(object({<br/>    name = string<br/>    security_rules = list(object({<br/>      name                       = string<br/>      priority                   = number<br/>      direction                  = string<br/>      access                     = string<br/>      protocol                   = string<br/>      source_port_range          = string<br/>      destination_port_range     = string<br/>      source_address_prefix      = string<br/>      destination_address_prefix = string<br/>    }))<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID for diagnostic settings | `string` | `null` | no |
| <a name="input_microsoft_peering"></a> [microsoft\_peering](#input\_microsoft\_peering) | Microsoft peering configuration | <pre>object({<br/>    primary_peer_address_prefix   = string<br/>    secondary_peer_address_prefix = string<br/>    vlan_id                       = number<br/>    peer_asn                      = optional(number, 65000)<br/>    advertised_public_prefixes    = list(string)<br/>    customer_asn                  = number<br/>    routing_registry_name         = string<br/>    ipv6 = optional(object({<br/>      primary_peer_address_prefix   = string<br/>      secondary_peer_address_prefix = string<br/>      microsoft_peering = object({<br/>        advertised_public_prefixes = list(string)<br/>        customer_asn               = number<br/>        routing_registry_name      = string<br/>      })<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_minimum_bandwidth_mbps"></a> [minimum\_bandwidth\_mbps](#input\_minimum\_bandwidth\_mbps) | Minimum required bandwidth in Mbps | `number` | `1000` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Prefix for ExpressRoute naming | `string` | `"expressroute"` | no |
| <a name="input_peering_location"></a> [peering\_location](#input\_peering\_location) | Location of the peering | `string` | n/a | yes |
| <a name="input_private_peering"></a> [private\_peering](#input\_private\_peering) | Private peering configuration | <pre>object({<br/>    primary_peer_address_prefix   = string<br/>    secondary_peer_address_prefix = string<br/>    vlan_id                       = number<br/>    peer_asn                      = optional(number, 65000)<br/>    ipv6 = optional(object({<br/>      primary_peer_address_prefix   = string<br/>      secondary_peer_address_prefix = string<br/>      microsoft_peering = object({<br/>        advertised_public_prefixes = list(string)<br/>        customer_asn               = number<br/>        routing_registry_name      = string<br/>      })<br/>    }))<br/>    route_filter_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_route_filters"></a> [route\_filters](#input\_route\_filters) | Route filter configurations | <pre>map(object({<br/>    name = string<br/>    rules = list(object({<br/>      name        = string<br/>      access      = string<br/>      rule_type   = string<br/>      communities = list(string)<br/>    }))<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_service_provider_name"></a> [service\_provider\_name](#input\_service\_provider\_name) | Name of the ExpressRoute service provider | `string` | n/a | yes |
| <a name="input_sku_family"></a> [sku\_family](#input\_sku\_family) | SKU family of the ExpressRoute circuit | `string` | `"MeteredData"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | SKU tier of the ExpressRoute circuit | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_circuit_authorization_keys"></a> [circuit\_authorization\_keys](#output\_circuit\_authorization\_keys) | Authorization keys for circuit connections |
| <a name="output_circuit_connection_ids"></a> [circuit\_connection\_ids](#output\_circuit\_connection\_ids) | IDs of the circuit connections |
| <a name="output_expressroute_circuit_id"></a> [expressroute\_circuit\_id](#output\_expressroute\_circuit\_id) | ID of the ExpressRoute circuit |
| <a name="output_expressroute_circuit_name"></a> [expressroute\_circuit\_name](#output\_expressroute\_circuit\_name) | Name of the ExpressRoute circuit |
| <a name="output_expressroute_circuit_service_key"></a> [expressroute\_circuit\_service\_key](#output\_expressroute\_circuit\_service\_key) | Service key for the ExpressRoute circuit |
| <a name="output_expressroute_circuit_service_provider_provisioning_state"></a> [expressroute\_circuit\_service\_provider\_provisioning\_state](#output\_expressroute\_circuit\_service\_provider\_provisioning\_state) | Service provider provisioning state |
| <a name="output_expressroute_gateway_ids"></a> [expressroute\_gateway\_ids](#output\_expressroute\_gateway\_ids) | IDs of the ExpressRoute gateways |
| <a name="output_expressroute_gateway_public_ips"></a> [expressroute\_gateway\_public\_ips](#output\_expressroute\_gateway\_public\_ips) | Public IP addresses of the ExpressRoute gateways |
| <a name="output_gateway_nsg_ids"></a> [gateway\_nsg\_ids](#output\_gateway\_nsg\_ids) | IDs of the gateway subnet NSGs |
| <a name="output_microsoft_peering_id"></a> [microsoft\_peering\_id](#output\_microsoft\_peering\_id) | ID of the Microsoft peering |
| <a name="output_private_peering_id"></a> [private\_peering\_id](#output\_private\_peering\_id) | ID of the private peering |
| <a name="output_route_filter_ids"></a> [route\_filter\_ids](#output\_route\_filter\_ids) | IDs of the route filters |
<!-- END_TF_DOCS -->

---

## Part of the AIRCLOUD Azure module catalog

Browse all modules with usage snippets in the [module catalog](https://aircloud-pl.github.io/) or on [github.com/AIRCLOUD-PL](https://github.com/AIRCLOUD-PL). Built and maintained by [AIRCLOUD](https://aircloud.com.pl): DevOps, cloud and AI engineering. Need a hand with Azure landing zones or platform engineering? See [aircloud.com.pl/consulting](https://aircloud.com.pl/consulting).
