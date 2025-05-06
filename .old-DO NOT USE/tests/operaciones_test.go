package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestOperacionesModule(t *testing.T) {
	// Configuración de Terratest
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/operaciones",
		Vars: map[string]interface{}{
			"region":              "us-east-1",
			"vpc_cidr_dev":        "10.0.0.0/16",
			"vpc_cidr_stage":      "10.1.0.0/16",
			"vpc_cidr_prod":       "10.2.0.0/16",
			"availability_zones":  []string{"us-east-1a", "us-east-1b"},
			"directory_name_dev":  "dev.local",
			"directory_name_stage": "stage.local",
			"directory_name_prod": "prod.local",
			"directory_password":  "TestPassword123!",
			"dev_account_id":      "111111111111",
			"stage_account_id":    "222222222222",
			"prod_account_id":     "333333333333",
		},
		PlanFilePath: "terraform_plan.out",
	})

	// Ejecutar terraform plan y validar que no hay errores
	terraform.InitAndPlan(t, terraformOptions)

	// Validar que los recursos se crean correctamente
	// Nota: Este test solo valida la sintaxis y estructura, no crea recursos reales
	output := terraform.InitAndPlanAndShow(t, terraformOptions)
	
	// Verificar que se crean los recursos esperados
	assert.Contains(t, output, "aws_vpc.vpc_operaciones_dev")
	assert.Contains(t, output, "aws_vpc.vpc_operaciones_stage")
	assert.Contains(t, output, "aws_vpc.vpc_operaciones_prod")
	assert.Contains(t, output, "aws_directory_service_directory.directory_dev")
	assert.Contains(t, output, "aws_directory_service_directory.directory_stage")
	assert.Contains(t, output, "aws_directory_service_directory.directory_prod")
	assert.Contains(t, output, "aws_ec2_transit_gateway.tgw")
	assert.Contains(t, output, "aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_operaciones_dev")
	assert.Contains(t, output, "aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_operaciones_stage")
	assert.Contains(t, output, "aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_operaciones_prod")
}
