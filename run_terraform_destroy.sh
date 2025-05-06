#!/bin/bash

# Script para ejecutar terraform destroy con los perfiles configurados

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

echo "ADVERTENCIA: Este comando eliminará toda la infraestructura creada."
echo "¿Estás seguro de que deseas continuar? (s/n)"
read respuesta

if [[ "$respuesta" != "s" && "$respuesta" != "S" ]]; then
  echo "Operación cancelada"
  exit 0
fi

echo "Ejecutando terraform destroy..."

# Ejecutar terraform destroy
terraform destroy \
  -var "region=$AWS_REGION" \
  -var "vpc_cidr_operaciones_dev=$VPC_CIDR_OPERACIONES_DEV" \
  -var "vpc_cidr_operaciones_stage=$VPC_CIDR_OPERACIONES_STAGE" \
  -var "vpc_cidr_operaciones_prod=$VPC_CIDR_OPERACIONES_PROD" \
  -var "vpc_cidr_dev=$VPC_CIDR_DEV" \
  -var "vpc_cidr_stage=$VPC_CIDR_STAGE" \
  -var "vpc_cidr_prod=$VPC_CIDR_PROD" \
  -var 'availability_zones=["us-east-1a", "us-east-1b"]' \
  -var "directory_name_dev=$DIRECTORY_NAME_DEV" \
  -var "directory_name_stage=$DIRECTORY_NAME_STAGE" \
  -var "directory_name_prod=$DIRECTORY_NAME_PROD" \
  -var "directory_password=$DIRECTORY_PASSWORD" \
  -var "operaciones_account_id=$OPERACIONES_ACCOUNT_ID" \
  -var "dev_account_id=$DEV_ACCOUNT_ID" \
  -var "stage_account_id=$STAGE_ACCOUNT_ID" \
  -var "prod_account_id=$PROD_ACCOUNT_ID" \
  -var "account_name_dev=$ACCOUNT_NAME_DEV" \
  -var "account_name_stage=$ACCOUNT_NAME_STAGE" \
  -var "account_name_prod=$ACCOUNT_NAME_PROD" \
  -var "account_name_operaciones=$ACCOUNT_NAME_OPERACIONES" \
  -var "vpc_name_dev=$VPC_NAME_DEV" \
  -var "vpc_name_stage=$VPC_NAME_STAGE" \
  -var "vpc_name_prod=$VPC_NAME_PROD" \
  -var "vpc_name_operaciones=$VPC_NAME_OPERACIONES" \
  -var "subnet_name_dev=$SUBNET_NAME_DEV" \
  -var "subnet_name_stage=$SUBNET_NAME_STAGE" \
  -var "subnet_name_prod=$SUBNET_NAME_PROD" \
  -var "subnet_name_operaciones=$SUBNET_NAME_OPERACIONES" \
  -var "igw_name_dev=$IGW_NAME_DEV" \
  -var "igw_name_stage=$IGW_NAME_STAGE" \
  -var "igw_name_prod=$IGW_NAME_PROD" \
  -var "igw_name_operaciones_dev=$IGW_NAME_OPERACIONES_DEV" \
  -var "igw_name_operaciones_stage=$IGW_NAME_OPERACIONES_STAGE" \
  -var "igw_name_operaciones_prod=$IGW_NAME_OPERACIONES_PROD" \
  -var "natgw_name_dev=$NATGW_NAME_DEV" \
  -var "natgw_name_stage=$NATGW_NAME_STAGE" \
  -var "natgw_name_prod=$NATGW_NAME_PROD" \
  -var "natgw_name_operaciones_dev=$NATGW_NAME_OPERACIONES_DEV" \
  -var "natgw_name_operaciones_stage=$NATGW_NAME_OPERACIONES_STAGE" \
  -var "natgw_name_operaciones_prod=$NATGW_NAME_OPERACIONES_PROD" \
  -var "eip_name_dev=$EIP_NAME_DEV" \
  -var "eip_name_stage=$EIP_NAME_STAGE" \
  -var "eip_name_prod=$EIP_NAME_PROD" \
  -var "eip_name_operaciones_dev=$EIP_NAME_OPERACIONES_DEV" \
  -var "eip_name_operaciones_stage=$EIP_NAME_OPERACIONES_STAGE" \
  -var "eip_name_operaciones_prod=$EIP_NAME_OPERACIONES_PROD" \
  -var "sg_directory_name_dev=$SG_DIRECTORY_NAME_DEV" \
  -var "sg_directory_name_stage=$SG_DIRECTORY_NAME_STAGE" \
  -var "sg_directory_name_prod=$SG_DIRECTORY_NAME_PROD" \
  -var "tgw_name=$TGW_NAME" \
  -var "tgw_description=$TGW_DESCRIPTION" \
  -var "tgw_attachment_name_dev=$TGW_ATTACHMENT_NAME_DEV" \
  -var "tgw_attachment_name_stage=$TGW_ATTACHMENT_NAME_STAGE" \
  -var "tgw_attachment_name_prod=$TGW_ATTACHMENT_NAME_PROD" \
  -var "tgw_attachment_name_operaciones_dev=$TGW_ATTACHMENT_NAME_OPERACIONES_DEV" \
  -var "tgw_attachment_name_operaciones_stage=$TGW_ATTACHMENT_NAME_OPERACIONES_STAGE" \
  -var "tgw_attachment_name_operaciones_prod=$TGW_ATTACHMENT_NAME_OPERACIONES_PROD" \
  -var "rt_name_dev_public=$RT_NAME_DEV_PUBLIC" \
  -var "rt_name_dev_private=$RT_NAME_DEV_PRIVATE" \
  -var "rt_name_stage_public=$RT_NAME_STAGE_PUBLIC" \
  -var "rt_name_stage_private=$RT_NAME_STAGE_PRIVATE" \
  -var "rt_name_prod_public=$RT_NAME_PROD_PUBLIC" \
  -var "rt_name_prod_private=$RT_NAME_PROD_PRIVATE" \
  -var "rt_name_operaciones_dev_public=$RT_NAME_OPERACIONES_DEV_PUBLIC" \
  -var "rt_name_operaciones_dev_private=$RT_NAME_OPERACIONES_DEV_PRIVATE" \
  -var "rt_name_operaciones_stage_public=$RT_NAME_OPERACIONES_STAGE_PUBLIC" \
  -var "rt_name_operaciones_stage_private=$RT_NAME_OPERACIONES_STAGE_PRIVATE" \
  -var "rt_name_operaciones_prod_public=$RT_NAME_OPERACIONES_PROD_PUBLIC" \
  -var "rt_name_operaciones_prod_private=$RT_NAME_OPERACIONES_PROD_PRIVATE" \
  -var "ram_share_name=$RAM_SHARE_NAME" \
  -var "aws_access_key_operaciones=$AWS_ACCESS_KEY_ID_OPERACIONES" \
  -var "aws_secret_key_operaciones=$AWS_SECRET_ACCESS_KEY_OPERACIONES" \
  -var "aws_access_key_dev=$AWS_ACCESS_KEY_ID_DEV" \
  -var "aws_secret_key_dev=$AWS_SECRET_ACCESS_KEY_DEV" \
  -var "aws_access_key_stage=$AWS_ACCESS_KEY_ID_STAGE" \
  -var "aws_secret_key_stage=$AWS_SECRET_ACCESS_KEY_STAGE" \
  -var "aws_access_key_prod=$AWS_ACCESS_KEY_ID_PROD" \
  -var "aws_secret_key_prod=$AWS_SECRET_ACCESS_KEY_PROD"

# Verificar si terraform destroy se ejecutó correctamente
if [ $? -eq 0 ]; then
  echo "Infraestructura eliminada correctamente"
else
  echo "Error al eliminar la infraestructura"
  exit 1
fi
