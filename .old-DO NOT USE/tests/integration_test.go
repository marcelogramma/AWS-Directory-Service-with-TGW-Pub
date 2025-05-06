package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestIntegration(t *testing.T) {
	// Configuración de Terratest
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"region":                    "us-east-1",
			"vpc_cidr_operaciones_dev":  "10.0.0.0/16",
			"vpc_cidr_operaciones_stage": "10.1.0.0/16",
			"vpc_cidr_operaciones_prod":  "10.2.0.0/16",
			"vpc_cidr_dev":              "10.10.0.0/16",
			"vpc_cidr_stage":            "10.20.0.0/16",
			"vpc_cidr_prod":             "10.30.0.0/16",
			"availability_zones":        []string{"us-east-1a", "us-east-1b"},
			"directory_name_dev":        "dev.local",
			"directory_name_stage":      "stage.local",
			"directory_name_prod":       "prod.local",
			"directory_password":        "TestPassword123!",
		},
		PlanFilePath: "terraform_plan.out",
	})

	// Ejecutar terraform plan y validar que no hay errores
	terraform.InitAndPlan(t, terraformOptions)

	// Validar que los recursos se crean correctamente
	output := terraform.InitAndPlanAndShow(t, terraformOptions)
	
	// Verificar que se crean los módulos esperados
	assert.Contains(t, output, "module.operaciones")
	assert.Contains(t, output, "module.dev")
	assert.Contains(t, output, "module.stage")
	assert.Contains(t, output, "module.prod")
	
	// Verificar que hay dependencias correctas
	assert.Contains(t, output, "depends_on")
}
