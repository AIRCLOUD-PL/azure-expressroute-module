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

output "private_peering_id" {
  description = "ID of the private peering"
  value       = module.expressroute.private_peering_id
}