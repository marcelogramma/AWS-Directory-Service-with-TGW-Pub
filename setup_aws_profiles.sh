#!/bin/bash

# Script para configurar los perfiles de AWS CLI y cargar variables de entorno

# Cargar variables de entorno desde .env
echo "Cargando variables de entorno desde .env..."
if [ -f .env ]; then
    source .env
else
    echo "Error: No se encontró el archivo .env"
    exit 1
fi

# Asegurar que el directorio ~/.aws existe
mkdir -p ~/.aws

# Verificar si el archivo de credenciales existe
if [ ! -f ~/.aws/credentials ]; then
    echo "Creando archivo de credenciales AWS..."
    touch ~/.aws/credentials
fi

# Función para verificar si un perfil existe en el archivo de credenciales
profile_exists() {
    local profile_name=$1
    grep -q "^\[$profile_name\]" ~/.aws/credentials
    return $?
}

# Función para actualizar o crear un perfil
update_profile() {
    local profile_name=$1
    local access_key=$2
    local secret_key=$3
    local region=$4
    
    if profile_exists "$profile_name"; then
        echo "El perfil [$profile_name] ya existe en ~/.aws/credentials"
    else
        echo "Agregando perfil [$profile_name] a ~/.aws/credentials"
        cat >> ~/.aws/credentials << EOF

[$profile_name]
aws_access_key_id = $access_key
aws_secret_access_key = $secret_key
region = $region
EOF
    fi
}

# Configurar los perfiles de AWS CLI si no existen
echo "Verificando y configurando perfiles AWS..."
update_profile "$ACCOUNT_NAME_OPERACIONES" "$AWS_ACCESS_KEY_ID_OPERACIONES" "$AWS_SECRET_ACCESS_KEY_OPERACIONES" "$AWS_REGION"
update_profile "$ACCOUNT_NAME_DEV" "$AWS_ACCESS_KEY_ID_DEV" "$AWS_SECRET_ACCESS_KEY_DEV" "$AWS_REGION"
update_profile "$ACCOUNT_NAME_STAGE" "$AWS_ACCESS_KEY_ID_STAGE" "$AWS_SECRET_ACCESS_KEY_STAGE" "$AWS_REGION"
update_profile "$ACCOUNT_NAME_PROD" "$AWS_ACCESS_KEY_ID_PROD" "$AWS_SECRET_ACCESS_KEY_PROD" "$AWS_REGION"

# Verificar que los perfiles se hayan configurado correctamente
echo "Perfiles de AWS CLI configurados:"
for profile in "$ACCOUNT_NAME_OPERACIONES" "$ACCOUNT_NAME_DEV" "$ACCOUNT_NAME_STAGE" "$ACCOUNT_NAME_PROD"; do
    if profile_exists "$profile"; then
        echo "- $profile ✅"
    else
        echo "- $profile ❌ (Error al configurar)"
    fi
done

# Exportar variables de entorno para Terraform
echo "Exportando variables de entorno para Terraform..."
export TF_VAR_region=$AWS_REGION
export TF_VAR_vpc_cidr_operaciones_dev=$VPC_CIDR_OPERACIONES_DEV
export TF_VAR_vpc_cidr_operaciones_stage=$VPC_CIDR_OPERACIONES_STAGE
export TF_VAR_vpc_cidr_operaciones_prod=$VPC_CIDR_OPERACIONES_PROD
export TF_VAR_vpc_cidr_dev=$VPC_CIDR_DEV
export TF_VAR_vpc_cidr_stage=$VPC_CIDR_STAGE
export TF_VAR_vpc_cidr_prod=$VPC_CIDR_PROD
export TF_VAR_directory_name_dev=$DIRECTORY_NAME_DEV
export TF_VAR_directory_name_stage=$DIRECTORY_NAME_STAGE
export TF_VAR_directory_name_prod=$DIRECTORY_NAME_PROD
export TF_VAR_directory_password=$DIRECTORY_PASSWORD
export TF_VAR_operaciones_account_id=$OPERACIONES_ACCOUNT_ID
export TF_VAR_dev_account_id=$DEV_ACCOUNT_ID
export TF_VAR_stage_account_id=$STAGE_ACCOUNT_ID
export TF_VAR_prod_account_id=$PROD_ACCOUNT_ID
export TF_VAR_account_name_dev=$ACCOUNT_NAME_DEV
export TF_VAR_account_name_stage=$ACCOUNT_NAME_STAGE
export TF_VAR_account_name_prod=$ACCOUNT_NAME_PROD
export TF_VAR_account_name_operaciones=$ACCOUNT_NAME_OPERACIONES
export TF_VAR_vpc_name_dev=$VPC_NAME_DEV
export TF_VAR_vpc_name_stage=$VPC_NAME_STAGE
export TF_VAR_vpc_name_prod=$VPC_NAME_PROD
export TF_VAR_vpc_name_operaciones=$VPC_NAME_OPERACIONES
export TF_VAR_subnet_name_dev=$SUBNET_NAME_DEV
export TF_VAR_subnet_name_stage=$SUBNET_NAME_STAGE
export TF_VAR_subnet_name_prod=$SUBNET_NAME_PROD
export TF_VAR_subnet_name_operaciones=$SUBNET_NAME_OPERACIONES
export TF_VAR_igw_name_dev=$IGW_NAME_DEV
export TF_VAR_igw_name_stage=$IGW_NAME_STAGE
export TF_VAR_igw_name_prod=$IGW_NAME_PROD
export TF_VAR_igw_name_operaciones_dev=$IGW_NAME_OPERACIONES_DEV
export TF_VAR_igw_name_operaciones_stage=$IGW_NAME_OPERACIONES_STAGE
export TF_VAR_igw_name_operaciones_prod=$IGW_NAME_OPERACIONES_PROD
export TF_VAR_natgw_name_dev=$NATGW_NAME_DEV
export TF_VAR_natgw_name_stage=$NATGW_NAME_STAGE
export TF_VAR_natgw_name_prod=$NATGW_NAME_PROD
export TF_VAR_natgw_name_operaciones_dev=$NATGW_NAME_OPERACIONES_DEV
export TF_VAR_natgw_name_operaciones_stage=$NATGW_NAME_OPERACIONES_STAGE
export TF_VAR_natgw_name_operaciones_prod=$NATGW_NAME_OPERACIONES_PROD
export TF_VAR_eip_name_dev=$EIP_NAME_DEV
export TF_VAR_eip_name_stage=$EIP_NAME_STAGE
export TF_VAR_eip_name_prod=$EIP_NAME_PROD
export TF_VAR_eip_name_operaciones_dev=$EIP_NAME_OPERACIONES_DEV
export TF_VAR_eip_name_operaciones_stage=$EIP_NAME_OPERACIONES_STAGE
export TF_VAR_eip_name_operaciones_prod=$EIP_NAME_OPERACIONES_PROD
export TF_VAR_sg_directory_name_dev=$SG_DIRECTORY_NAME_DEV
export TF_VAR_sg_directory_name_stage=$SG_DIRECTORY_NAME_STAGE
export TF_VAR_sg_directory_name_prod=$SG_DIRECTORY_NAME_PROD
export TF_VAR_tgw_name=$TGW_NAME
export TF_VAR_tgw_description=$TGW_DESCRIPTION
export TF_VAR_tgw_attachment_name_dev=$TGW_ATTACHMENT_NAME_DEV
export TF_VAR_tgw_attachment_name_stage=$TGW_ATTACHMENT_NAME_STAGE
export TF_VAR_tgw_attachment_name_prod=$TGW_ATTACHMENT_NAME_PROD
export TF_VAR_tgw_attachment_name_operaciones_dev=$TGW_ATTACHMENT_NAME_OPERACIONES_DEV
export TF_VAR_tgw_attachment_name_operaciones_stage=$TGW_ATTACHMENT_NAME_OPERACIONES_STAGE
export TF_VAR_tgw_attachment_name_operaciones_prod=$TGW_ATTACHMENT_NAME_OPERACIONES_PROD
export TF_VAR_rt_name_dev_public=$RT_NAME_DEV_PUBLIC
export TF_VAR_rt_name_dev_private=$RT_NAME_DEV_PRIVATE
export TF_VAR_rt_name_stage_public=$RT_NAME_STAGE_PUBLIC
export TF_VAR_rt_name_stage_private=$RT_NAME_STAGE_PRIVATE
export TF_VAR_rt_name_prod_public=$RT_NAME_PROD_PUBLIC
export TF_VAR_rt_name_prod_private=$RT_NAME_PROD_PRIVATE
export TF_VAR_rt_name_operaciones_dev_public=$RT_NAME_OPERACIONES_DEV_PUBLIC
export TF_VAR_rt_name_operaciones_dev_private=$RT_NAME_OPERACIONES_DEV_PRIVATE
export TF_VAR_rt_name_operaciones_stage_public=$RT_NAME_OPERACIONES_STAGE_PUBLIC
export TF_VAR_rt_name_operaciones_stage_private=$RT_NAME_OPERACIONES_STAGE_PRIVATE
export TF_VAR_rt_name_operaciones_prod_public=$RT_NAME_OPERACIONES_PROD_PUBLIC
export TF_VAR_rt_name_operaciones_prod_private=$RT_NAME_OPERACIONES_PROD_PRIVATE
export TF_VAR_ram_share_name=$RAM_SHARE_NAME
export TF_VAR_aws_access_key_operaciones=$AWS_ACCESS_KEY_ID_OPERACIONES
export TF_VAR_aws_secret_key_operaciones=$AWS_SECRET_ACCESS_KEY_OPERACIONES
export TF_VAR_aws_access_key_dev=$AWS_ACCESS_KEY_ID_DEV
export TF_VAR_aws_secret_key_dev=$AWS_SECRET_ACCESS_KEY_DEV
export TF_VAR_aws_access_key_stage=$AWS_ACCESS_KEY_ID_STAGE
export TF_VAR_aws_secret_key_stage=$AWS_SECRET_ACCESS_KEY_STAGE
export TF_VAR_aws_access_key_prod=$AWS_ACCESS_KEY_ID_PROD
export TF_VAR_aws_secret_key_prod=$AWS_SECRET_ACCESS_KEY_PROD

echo "Configuración completada exitosamente"
