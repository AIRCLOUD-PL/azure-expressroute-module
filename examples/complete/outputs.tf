output "expressroute_circuit_id" {
  description = "ID of the ExpressRoute circuit"
  value       = module.expressroute.expressroute_circuit_id
}

output "expressroute_circuit_name" {
  description = "Name of the ExpressRoute circuit"
  value       = module.expressroute.expressroute_circuit_name
}

output "expressroute_circuit_service_key" {
  description = "Service key for the ExpressRoute circuit"
  value       = module.expressroute.expressroute_circuit_service_key
  sensitive   = true
}

output "circuit_authorization_keys" {
  description = "Authorization keys for circuit connections"
  value       = module.expressroute.circuit_authorization_keys
  sensitive   = true
}

output "private_peering_id" {
  description = "ID of the private peering"
  value       = module.expressroute.private_peering_id
}

output "microsoft_peering_id" {
  description = "ID of the Microsoft peering"
  value       = module.expressroute.microsoft_peering_id
}

output "expressroute_gateway_ids" {
  description = "IDs of the ExpressRoute gateways"
  value       = module.expressroute.expressroute_gateway_ids
}

output "expressroute_gateway_public_ips" {
  description = "Public IP addresses of the ExpressRoute gateways"
  value       = module.expressroute.expressroute_gateway_public_ips
}

output "circuit_connection_ids" {
  description = "IDs of the circuit connections"
  value       = module.expressroute.circuit_connection_ids
}

output "route_filter_ids" {
  description = "IDs of the route filters"
  value       = module.expressroute.route_filter_ids
}

output "gateway_nsg_ids" {
  description = "IDs of the gateway subnet NSGs"
  value       = module.expressroute.gateway_nsg_ids
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.example.id
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.example.id
}

output "gateway_subnet_id" {
  description = "ID of the gateway subnet"
  value       = azurerm_subnet.gateway.id
}