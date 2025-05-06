#!/bin/bash

# Script para corregir las rutas del Transit Gateway

# Cargar variables de entorno y configurar perfiles
source ./setup_aws_profiles.sh

# Verificar que los perfiles se hayan configurado correctamente
if [ $? -ne 0 ]; then
  echo "Error: No se pudieron configurar los perfiles de AWS CLI"
  exit 1
fi

echo "Verificando Transit Gateway..."
TGW_ID=$(aws ec2 describe-transit-gateways --profile $ACCOUNT_NAME_OPERACIONES --query "TransitGateways[?State=='available'].TransitGatewayId" --output text)

if [ -z "$TGW_ID" ]; then
  echo "Error: No se encontró un Transit Gateway disponible"
  exit 1
fi

echo "Transit Gateway encontrado: $TGW_ID"

# Actualizar las rutas en los módulos
echo "Actualizando rutas en el módulo de operaciones..."

# Obtener las tablas de rutas
RT_DEV=$(aws ec2 describe-route-tables --profile $ACCOUNT_NAME_OPERACIONES --filters "Name=tag:Name,Values=rt-operaciones-dev-private" --query "RouteTables[0].RouteTableId" --output text)
RT_STAGE=$(aws ec2 describe-route-tables --profile $ACCOUNT_NAME_OPERACIONES --filters "Name=tag:Name,Values=rt-operaciones-stage-private" --query "RouteTables[0].RouteTableId" --output text)
RT_PROD=$(aws ec2 describe-route-tables --profile $ACCOUNT_NAME_OPERACIONES --filters "Name=tag:Name,Values=rt-operaciones-prod-private" --query "RouteTables[0].RouteTableId" --output text)

# Crear rutas para Dev
if [ ! -z "$RT_DEV" ]; then
  echo "Creando rutas para Dev..."
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_DEV --destination-cidr-block $VPC_CIDR_OPERACIONES_STAGE --transit-gateway-id $TGW_ID
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_DEV --destination-cidr-block $VPC_CIDR_OPERACIONES_PROD --transit-gateway-id $TGW_ID
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_DEV --destination-cidr-block $VPC_CIDR_DEV --transit-gateway-id $TGW_ID
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_DEV --destination-cidr-block $VPC_CIDR_STAGE --transit-gateway-id $TGW_ID
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_DEV --destination-cidr-block $VPC_CIDR_PROD --transit-gateway-id $TGW_ID
fi

# Crear rutas para Stage
if [ ! -z "$RT_STAGE" ]; then
  echo "Creando rutas para Stage..."
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_STAGE --destination-cidr-block $VPC_CIDR_OPERACIONES_DEV --transit-gateway-id $TGW_ID
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_STAGE --destination-cidr-block $VPC_CIDR_OPERACIONES_PROD --transit-gateway-id $TGW_ID
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_STAGE --destination-cidr-block $VPC_CIDR_DEV --transit-gateway-id $TGW_ID
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_STAGE --destination-cidr-block $VPC_CIDR_STAGE --transit-gateway-id $TGW_ID
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_STAGE --destination-cidr-block $VPC_CIDR_PROD --transit-gateway-id $TGW_ID
fi

# Crear rutas para Prod
if [ ! -z "$RT_PROD" ]; then
  echo "Creando rutas para Prod..."
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_PROD --destination-cidr-block $VPC_CIDR_OPERACIONES_DEV --transit-gateway-id $TGW_ID
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_PROD --destination-cidr-block $VPC_CIDR_OPERACIONES_STAGE --transit-gateway-id $TGW_ID
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_PROD --destination-cidr-block $VPC_CIDR_DEV --transit-gateway-id $TGW_ID
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_PROD --destination-cidr-block $VPC_CIDR_STAGE --transit-gateway-id $TGW_ID
  aws ec2 create-route --profile $ACCOUNT_NAME_OPERACIONES --route-table-id $RT_PROD --destination-cidr-block $VPC_CIDR_PROD --transit-gateway-id $TGW_ID
fi

echo "Rutas del Transit Gateway corregidas correctamente"
