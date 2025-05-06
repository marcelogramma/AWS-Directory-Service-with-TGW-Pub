#!/bin/bash

# Cargar variables de entorno desde el archivo .env
if [ -f .env ]; then
  echo "Cargando variables de entorno desde .env..."
  export $(grep -v '^#' .env | xargs)
else
  echo "Error: Archivo .env no encontrado"
  exit 1
fi

# Verificar que el archivo main.tf tenga los perfiles correctos
echo "Verificando y actualizando los perfiles AWS en main.tf..."
if grep -q "profile = \"nubity\"" main.tf; then
  echo "Actualizando perfiles en main.tf..."
  sed -i 's/profile = "nubity"/profile = "operaciones"/' main.tf
  sed -i 's/alias  = "dev"\n  profile = "operaciones"/alias  = "dev"\n  profile = "dev"/' main.tf
  sed -i 's/alias  = "stage"\n  profile = "operaciones"/alias  = "stage"\n  profile = "stage"/' main.tf
  sed -i 's/alias  = "prod"\n  profile = "operaciones"/alias  = "prod"\n  profile = "prod"/' main.tf
else
  echo "Los perfiles ya están configurados correctamente."
fi

# Configurar credenciales de AWS para cada cuenta en el archivo ~/.aws/credentials
#mkdir -p ~/.aws

#cat > ~/.aws/credentials << EOF
#[operaciones]
#aws_access_key_id = $AWS_ACCESS_KEY_ID_OPERACIONES
#aws_secret_access_key = $AWS_SECRET_ACCESS_KEY_OPERACIONES

#[dev]
#aws_access_key_id = $AWS_ACCESS_KEY_ID_DEV
#aws_secret_access_key = $AWS_SECRET_ACCESS_KEY_DEV

#[stage]
#aws_access_key_id = $AWS_ACCESS_KEY_ID_STAGE
#aws_secret_access_key = $AWS_SECRET_ACCESS_KEY_STAGE

#[prod]
#aws_access_key_id = $AWS_ACCESS_KEY_ID_PROD
#aws_secret_access_key = $AWS_SECRET_ACCESS_KEY_PROD
#EOF

#chmod 600 ~/.aws/credentials

# Ejecutar terraform apply enfocado en los recursos que fallaron anteriormente
echo "Ejecutando terraform apply para crear los attachments y rutas faltantes..."
terraform apply -var-file=terraform.tfvars -target=module.dev.aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_dev -target=module.stage.aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_stage -target=module.prod.aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_prod -target=module.dev.aws_route.route_to_operaciones_dev -target=module.dev.aws_route.route_to_operaciones_stage -target=module.dev.aws_route.route_to_operaciones_prod -target=module.stage.aws_route.route_to_operaciones_dev -target=module.stage.aws_route.route_to_operaciones_stage -target=module.stage.aws_route.route_to_operaciones_prod -target=module.prod.aws_route.route_to_operaciones_dev -target=module.prod.aws_route.route_to_operaciones_stage -target=module.prod.aws_route.route_to_operaciones_prod -auto-approve

# Limpiar variables de entorno sensibles
unset AWS_ACCESS_KEY_ID_OPERACIONES
unset AWS_SECRET_ACCESS_KEY_OPERACIONES
unset AWS_ACCESS_KEY_ID_DEV
unset AWS_SECRET_ACCESS_KEY_DEV
unset AWS_ACCESS_KEY_ID_STAGE
unset AWS_SECRET_ACCESS_KEY_STAGE
unset AWS_ACCESS_KEY_ID_PROD
unset AWS_SECRET_ACCESS_KEY_PROD
unset DIRECTORY_PASSWORD

echo "Proceso de aplicación completado."
