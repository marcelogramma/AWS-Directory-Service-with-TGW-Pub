#!/bin/bash

# Cargar variables de entorno y configurar perfiles
source ./setup_aws_profiles.sh

# Verificar que los perfiles se hayan configurado correctamente
if [ $? -ne 0 ]; then
  echo "Error: No se pudieron configurar los perfiles de AWS CLI"
  exit 1
fi

# Verificar la conectividad con AWS
echo "Verificando conectividad con AWS..."
for profile in $ACCOUNT_NAME_OPERACIONES $ACCOUNT_NAME_DEV $ACCOUNT_NAME_STAGE $ACCOUNT_NAME_PROD; do
  echo "Verificando perfil: $profile"
  aws sts get-caller-identity --profile $profile
  if [ $? -ne 0 ]; then
    echo "Error: No se pudo conectar a AWS con el perfil $profile"
    exit 1
  fi
done

echo "Usando perfiles de AWS: $ACCOUNT_NAME_OPERACIONES, $ACCOUNT_NAME_DEV, $ACCOUNT_NAME_STAGE, $ACCOUNT_NAME_PROD"
echo "Región AWS: $AWS_REGION"

# Obtener IDs de los Directory Services
echo "Obteniendo IDs de los Directory Services..."
DIRECTORY_DEV=$(terraform output -json directory_service_ids | jq -r '.dev')
DIRECTORY_STAGE=$(terraform output -json directory_service_ids | jq -r '.stage')
DIRECTORY_PROD=$(terraform output -json directory_service_ids | jq -r '.prod')

echo "Directory Service $ACCOUNT_NAME_DEV: $DIRECTORY_DEV"
echo "Directory Service $ACCOUNT_NAME_STAGE: $DIRECTORY_STAGE"
echo "Directory Service $ACCOUNT_NAME_PROD: $DIRECTORY_PROD"

# Verificar estado de los Directory Services
echo "Verificando estado de los Directory Services..."
echo "Directory Service $ACCOUNT_NAME_DEV:"
aws ds describe-directories --directory-ids $DIRECTORY_DEV --profile $ACCOUNT_NAME_OPERACIONES --region $AWS_REGION --output json

echo "Directory Service $ACCOUNT_NAME_STAGE:"
aws ds describe-directories --directory-ids $DIRECTORY_STAGE --profile $ACCOUNT_NAME_OPERACIONES --region $AWS_REGION --output json

echo "Directory Service $ACCOUNT_NAME_PROD:"
aws ds describe-directories --directory-ids $DIRECTORY_PROD --profile $ACCOUNT_NAME_OPERACIONES --region $AWS_REGION --output json

echo "Pruebas de Directory Service completadas."
