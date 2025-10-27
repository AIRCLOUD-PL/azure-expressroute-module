# ExpressRoute Module

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

### Basic Example - Private Peering

```hcl
module "expressroute" {
  source = "./modules/network/expressroute"

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
  source = "./modules/network/expressroute"

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

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.80.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.80.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| expressroute_circuit_name | Name of the ExpressRoute circuit | `string` | `null` | no |
| naming_prefix | Prefix for ExpressRoute naming | `string` | `"expressroute"` | no |
| environment | Environment name | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| service_provider_name | ExpressRoute service provider | `string` | n/a | yes |
| peering_location | Peering location | `string` | n/a | yes |
| bandwidth_in_mbps | Bandwidth in Mbps | `number` | n/a | yes |
| sku_tier | SKU tier | `string` | `"Standard"` | no |
| sku_family | SKU family | `string` | `"MeteredData"` | no |
| allow_classic_operations | Allow classic operations | `bool` | `false` | no |
| express_route_port_id | ExpressRoute port ID | `string` | `null` | no |
| circuit_authorizations | Circuit authorization configs | `map` | `{}` | no |
| enable_private_peering | Enable private peering | `bool` | `true` | no |
| private_peering | Private peering config | `object` | `null` | no |
| enable_microsoft_peering | Enable Microsoft peering | `bool` | `false` | no |
| microsoft_peering | Microsoft peering config | `object` | `null` | no |
| expressroute_gateways | Gateway configurations | `map` | `{}` | no |
| circuit_connections | Circuit connection configs | `map` | `{}` | no |
| route_filters | Route filter configs | `map` | `{}` | no |
| gateway_subnet_nsgs | NSG configurations | `map` | `{}` | no |
| diagnostic_settings | Diagnostic settings | `map` | `{}` | no |
| enable_policy_assignments | Enable policy assignments | `bool` | `true` | no |
| enable_custom_policies | Enable custom policies | `bool` | `false` | no |
| minimum_bandwidth_mbps | Minimum bandwidth | `number` | `1000` | no |
| log_analytics_workspace_id | Log Analytics workspace ID | `string` | `null` | no |
| tags | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| expressroute_circuit_id | Circuit ID |
| expressroute_circuit_name | Circuit name |
| expressroute_circuit_service_key | Service key (sensitive) |
| circuit_authorization_keys | Authorization keys (sensitive) |
| private_peering_id | Private peering ID |
| microsoft_peering_id | Microsoft peering ID |
| expressroute_gateway_ids | Gateway IDs |
| expressroute_gateway_public_ips | Gateway public IPs |
| circuit_connection_ids | Connection IDs |
| route_filter_ids | Route filter IDs |
| gateway_nsg_ids | NSG IDs |

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
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
