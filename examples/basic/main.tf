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

module "expressroute" {
  source = "../../"

  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  environment           = var.environment
  service_provider_name = var.service_provider_name
  peering_location      = var.peering_location
  bandwidth_in_mbps     = var.bandwidth_in_mbps

  # Basic configuration with Standard SKU
  sku_tier   = "Standard"
  sku_family = "MeteredData"

  # Enable private peering
  enable_private_peering = true
  private_peering = {
    primary_peer_address_prefix   = "192.168.1.0/30"
    secondary_peer_address_prefix = "192.168.1.4/30"
    vlan_id                       = 100
    peer_asn                      = 65000
  }

  # Tags
  tags = {
    Environment = var.environment
    Project     = "expressroute-basic-example"
  }
}