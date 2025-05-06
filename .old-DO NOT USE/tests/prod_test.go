package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestProdModule(t *testing.T) {
	// Configuración de Terratest
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/prod",
		Vars: map[string]interface{}{
			"region":                  "us-east-1",
			"vpc_cidr":                "10.30.0.0/16",
			"availability_zones":      []string{"us-east-1a", "us-east-1b"},
			"transit_gateway_id":      "tgw-12345",
			"operaciones_vpc_cidr_dev":   "10.0.0.0/16",
			"operaciones_vpc_cidr_stage": "10.1.0.0/16",
			"operaciones_vpc_cidr_prod":  "10.2.0.0/16",
		},
		PlanFilePath: "terraform_plan.out",
	})

	// Ejecutar terraform plan y validar que no hay errores
	terraform.InitAndPlan(t, terraformOptions)

	// Validar que los recursos se crean correctamente
	output := terraform.InitAndPlanAndShow(t, terraformOptions)
	
	// Verificar que se crean los recursos esperados
	assert.Contains(t, output, "aws_vpc.vpc_prod")
	assert.Contains(t, output, "aws_subnet.subnet_prod")
	assert.Contains(t, output, "aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_prod")
	assert.Contains(t, output, "aws_route_table.rt_prod")
	assert.Contains(t, output, "aws_route.route_to_operaciones_dev")
	assert.Contains(t, output, "aws_route.route_to_operaciones_stage")
	assert.Contains(t, output, "aws_route.route_to_operaciones_prod")
}
