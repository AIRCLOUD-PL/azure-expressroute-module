output "expressroute_circuit_id" {
  description = "ID of the ExpressRoute circuit"
  value       = azurerm_express_route_circuit.main.id
}

output "expressroute_circuit_name" {
  description = "Name of the ExpressRoute circuit"
  value       = azurerm_express_route_circuit.main.name
}

output "expressroute_circuit_service_provider_provisioning_state" {
  description = "Service provider provisioning state"
  value       = azurerm_express_route_circuit.main.service_provider_provisioning_state
}

output "expressroute_circuit_service_key" {
  description = "Service key for the ExpressRoute circuit"
  value       = azurerm_express_route_circuit.main.service_key
}

output "circuit_authorization_keys" {
  description = "Authorization keys for circuit connections"
  value = {
    for k, v in azurerm_express_route_circuit_authorization.authorizations :
    k => v.authorization_key
  }
  sensitive = true
}

output "private_peering_id" {
  description = "ID of the private peering"
  value       = var.enable_private_peering ? azurerm_express_route_circuit_peering.private_peering[0].id : null
}

output "microsoft_peering_id" {
  description = "ID of the Microsoft peering"
  value       = var.enable_microsoft_peering ? azurerm_express_route_circuit_peering.microsoft_peering[0].id : null
}

output "expressroute_gateway_ids" {
  description = "IDs of the ExpressRoute gateways"
  value = {
    for k, v in azurerm_virtual_network_gateway.expressroute_gateway :
    k => v.id
  }
}

output "expressroute_gateway_public_ips" {
  description = "Public IP addresses of the ExpressRoute gateways"
  value = {
    for k, v in azurerm_virtual_network_gateway.expressroute_gateway :
    k => v.bgp_settings[0].peering_addresses[0].tunnel_ip_addresses
  }
}

output "circuit_connection_ids" {
  description = "IDs of the circuit connections"
  value = {
    for k, v in azurerm_express_route_circuit_connection.connections :
    k => v.id
  }
}

output "route_filter_ids" {
  description = "IDs of the route filters"
  value = {
    for k, v in azurerm_route_filter.route_filters :
    k => v.id
  }
}

output "gateway_nsg_ids" {
  description = "IDs of the gateway subnet NSGs"
  value = {
    for k, v in azurerm_network_security_group.gateway_subnets :
    k => v.id
  }
}