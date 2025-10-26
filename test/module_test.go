package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestExpressRouteModuleBasic(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",

		Vars: map[string]interface{}{
			"resource_group_name":   "rg-test-expressroute-basic",
			"location":             "westeurope",
			"environment":          "test",
			"service_provider_name": "Equinix",
			"peering_location":     "Amsterdam",
			"bandwidth_in_mbps":    1000,
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_express_route_circuit.main")
}

func TestExpressRouteModuleWithPrivatePeering(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",

		Vars: map[string]interface{}{
			"resource_group_name":   "rg-test-expressroute-private",
			"location":             "westeurope",
			"environment":          "test",
			"service_provider_name": "Equinix",
			"peering_location":     "Amsterdam",
			"bandwidth_in_mbps":    1000,
			"enable_private_peering": true,
			"private_peering": map[string]interface{}{
				"primary_peer_address_prefix":   "192.168.1.0/30",
				"secondary_peer_address_prefix": "192.168.1.4/30",
				"vlan_id":                      100,
				"peer_asn":                     65000,
			},
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_express_route_circuit.main")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_express_route_circuit_peering.private_peering")
}

func TestExpressRouteModuleWithMicrosoftPeering(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",

		Vars: map[string]interface{}{
			"resource_group_name":   "rg-test-expressroute-microsoft",
			"location":             "westeurope",
			"environment":          "test",
			"service_provider_name": "Equinix",
			"peering_location":     "Amsterdam",
			"bandwidth_in_mbps":    1000,
			"enable_microsoft_peering": true,
			"microsoft_peering": map[string]interface{}{
				"primary_peer_address_prefix":   "192.168.2.0/30",
				"secondary_peer_address_prefix": "192.168.2.4/30",
				"vlan_id":                      200,
				"peer_asn":                     65000,
				"advertised_public_prefixes":   []string{"203.0.113.0/24"},
				"customer_asn":                 65001,
				"routing_registry_name":        "ARIN",
			},
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_express_route_circuit.main")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_express_route_circuit_peering.microsoft_peering")
}

func TestExpressRouteModuleWithCircuitAuthorizations(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",

		Vars: map[string]interface{}{
			"resource_group_name":   "rg-test-expressroute-auth",
			"location":             "westeurope",
			"environment":          "test",
			"service_provider_name": "Equinix",
			"peering_location":     "Amsterdam",
			"bandwidth_in_mbps":    1000,
			"circuit_authorizations": map[string]interface{}{
				"auth1": map[string]interface{}{
					"name": "authorization-1",
				},
			},
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_express_route_circuit_authorization.authorizations")
}

func TestExpressRouteModulePremiumSku(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",

		Vars: map[string]interface{}{
			"resource_group_name":   "rg-test-expressroute-premium",
			"location":             "westeurope",
			"environment":          "test",
			"service_provider_name": "Equinix",
			"peering_location":     "Amsterdam",
			"bandwidth_in_mbps":    1000,
			"sku_tier":            "Premium",
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	resourceChanges := terraform.GetResourceChanges(t, planStruct)

	for _, change := range resourceChanges {
		if change.Type == "azurerm_express_route_circuit" && change.Change.After != nil {
			afterMap := change.Change.After.(map[string]interface{})
			if sku, ok := afterMap["sku"]; ok {
				skuMap := sku.([]interface{})[0].(map[string]interface{})
				if tier, ok := skuMap["tier"]; ok {
					assert.Equal(t, "Premium", tier.(string), "ExpressRoute circuit should use Premium SKU")
				}
			}
		}
	}
}

func TestExpressRouteModuleNamingConvention(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",

		Vars: map[string]interface{}{
			"resource_group_name":   "rg-test-expressroute-naming",
			"location":             "westeurope",
			"environment":          "prod",
			"service_provider_name": "Equinix",
			"peering_location":     "Amsterdam",
			"bandwidth_in_mbps":    1000,
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	resourceChanges := terraform.GetResourceChanges(t, planStruct)

	for _, change := range resourceChanges {
		if change.Type == "azurerm_express_route_circuit" && change.Change.After != nil {
			afterMap := change.Change.After.(map[string]interface{})
			if name, ok := afterMap["name"]; ok {
				circuitName := name.(string)
				assert.Contains(t, circuitName, "prod", "ExpressRoute circuit name should contain environment")
			}
		}
	}
}