variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "service_provider_name" {
  description = "ExpressRoute service provider name"
  type        = string
  default     = "Equinix"
}

variable "peering_location" {
  description = "Peering location"
  type        = string
  default     = "Amsterdam"
}

variable "bandwidth_in_mbps" {
  description = "Bandwidth in Mbps"
  type        = number
  default     = 1000
}