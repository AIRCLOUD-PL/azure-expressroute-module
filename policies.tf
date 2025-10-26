# Azure Policy Assignments for ExpressRoute Security and Compliance

# Require encryption in transit for ExpressRoute circuits
resource "azurerm_subscription_policy_assignment" "expressroute_encryption" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "expressroute-encryption-${var.environment}"
  subscription_id      = data.azurerm_client_config.current.subscription_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1e5c2aac-f5d0-42b6-8ce7-612c3d7a76d1" # Require encryption in transit

  parameters = jsonencode({
    effect = {
      value = "Deny"
    }
  })
}

# Audit ExpressRoute circuits without private peering
resource "azurerm_subscription_policy_assignment" "expressroute_private_peering" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "expressroute-private-peering-${var.environment}"
  subscription_id      = data.azurerm_client_config.current.subscription_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4b1b0b94-019b-45c0-9c8c-4a24a945fc84" # ExpressRoute circuits should have private peering enabled

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# Require diagnostic settings for ExpressRoute circuits
resource "azurerm_subscription_policy_assignment" "expressroute_diagnostics" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "expressroute-diagnostics-${var.environment}"
  subscription_id      = data.azurerm_client_config.current.subscription_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/c651dd59-534d-4cb0-8d6c-140e68ebf897" # Diagnostic settings should be enabled on ExpressRoute circuits

  parameters = jsonencode({
    effect = {
      value = "DeployIfNotExists"
    }
    profileName = {
      value = "setByPolicy"
    }
    logAnalyticsWorkspaceId = {
      value = var.log_analytics_workspace_id
    }
    metricsEnabled = {
      value = "true"
    }
    logsEnabled = {
      value = "true"
    }
  })
}

# Require ExpressRoute circuits to use Premium SKU for high availability
resource "azurerm_subscription_policy_assignment" "expressroute_premium_sku" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "expressroute-premium-sku-${var.environment}"
  subscription_id      = data.azurerm_client_config.current.subscription_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4b1b0b94-019b-45c0-9c8c-4a24a945fc84" # ExpressRoute circuits should use Premium SKU

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
    skuTier = {
      value = "Premium"
    }
  })
}

# Custom policy for ExpressRoute circuit bandwidth validation
resource "azurerm_policy_definition" "expressroute_bandwidth_policy" {
  count = var.enable_custom_policies ? 1 : 0

  name         = "expressroute-bandwidth-validation"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "ExpressRoute circuits should have minimum bandwidth"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Network/expressRouteCircuits"
        },
        {
          field = "Microsoft.Network/expressRouteCircuits/bandwidthInMbps"
          less  = var.minimum_bandwidth_mbps
        }
      ]
    }
    then = {
      effect = "Deny"
    }
  })

  parameters = jsonencode({
    minimumBandwidthMbps = {
      type = "Integer"
      metadata = {
        displayName = "Minimum bandwidth in Mbps"
        description = "Minimum required bandwidth for ExpressRoute circuits"
      }
      defaultValue = 1000
    }
  })
}

# Policy assignment for custom bandwidth policy
resource "azurerm_subscription_policy_assignment" "expressroute_bandwidth_assignment" {
  count = var.enable_custom_policies ? 1 : 0

  name                 = "expressroute-bandwidth-${var.environment}"
  subscription_id      = data.azurerm_client_config.current.subscription_id
  policy_definition_id = azurerm_policy_definition.expressroute_bandwidth_policy[0].id

  parameters = jsonencode({
    minimumBandwidthMbps = {
      value = var.minimum_bandwidth_mbps
    }
  })
}

# Require route filters on ExpressRoute circuits
resource "azurerm_subscription_policy_assignment" "expressroute_route_filters" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "expressroute-route-filters-${var.environment}"
  subscription_id      = data.azurerm_client_config.current.subscription_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4b1b0b94-019b-45c0-9c8c-4a24a945fc84" # ExpressRoute circuits should have route filters

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# Data source for client configuration
data "azurerm_client_config" "current" {}