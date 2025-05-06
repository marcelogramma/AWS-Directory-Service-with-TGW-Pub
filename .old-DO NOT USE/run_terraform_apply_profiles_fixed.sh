#!/bin/bash

# Script mejorado para aplicar Terraform con múltiples perfiles AWS
# y manejar errores comunes en la creación de recursos

# Cargar variables de entorno desde el archivo .env
if [ -f .env ]; then
  echo "Cargando variables de entorno desde .env..."
  export $(grep -v '^#' .env | xargs)
else
  echo "Error: Archivo .env no encontrado"
  exit 1
fi

# Actualizar el archivo terraform.tfvars con la contraseña del directorio
if [ -n "$DIRECTORY_PASSWORD" ]; then
  echo "Actualizando la contraseña del directorio en terraform.tfvars..."
  sed -i "s/directory_password     = \".*\"/directory_password     = \"$DIRECTORY_PASSWORD\"/" terraform.tfvars
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

# Ejecutar terraform apply
echo "Ejecutando terraform apply..."
terraform apply -var-file=terraform.tfvars -auto-approve

# Verificar si hay errores relacionados con Transit Gateway
if grep -q "InvalidTransitGatewayID.NotFound" terraform.tfstate; then
  echo "Se detectaron errores con el Transit Gateway. Ejecutando script de corrección..."
  ./fix_transit_gateway_routes.sh
fi

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

echo "Proceso completado."
