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

# Obtener ID del Transit Gateway
echo "Obteniendo ID del Transit Gateway..."
TGW_ID=$(terraform output -raw transit_gateway_id)
echo "Transit Gateway ID: $TGW_ID"

# Verificar estado del Transit Gateway
echo "Verificando estado del Transit Gateway..."
aws ec2 describe-transit-gateways --transit-gateway-ids $TGW_ID --profile $ACCOUNT_NAME_OPERACIONES --region $AWS_REGION --output json

# Verificar Transit Gateway Attachments
echo "Verificando Transit Gateway Attachments..."
echo "Attachments en cuenta $ACCOUNT_NAME_OPERACIONES:"
aws ec2 describe-transit-gateway-attachments --filters "Name=transit-gateway-id,Values=$TGW_ID" --profile $ACCOUNT_NAME_OPERACIONES --region $AWS_REGION --output json

echo "Pruebas de Transit Gateway completadas."
