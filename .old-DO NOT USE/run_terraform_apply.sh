#!/bin/bash

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

# Configurar credenciales de AWS para cada cuenta
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID_OPERACIONES
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY_OPERACIONES

# Ejecutar terraform apply
echo "Ejecutando terraform apply..."
terraform apply -var-file=terraform.tfvars -auto-approve

# Limpiar variables de entorno sensibles
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID_OPERACIONES
unset AWS_SECRET_ACCESS_KEY_OPERACIONES
unset AWS_ACCESS_KEY_ID_DEV
unset AWS_SECRET_ACCESS_KEY_DEV
unset AWS_ACCESS_KEY_ID_STAGE
unset AWS_SECRET_ACCESS_KEY_STAGE
unset AWS_ACCESS_KEY_ID_PROD
unset AWS_SECRET_ACCESS_KEY_PROD
unset DIRECTORY_PASSWORD
