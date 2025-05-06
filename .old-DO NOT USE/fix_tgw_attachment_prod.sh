#!/bin/bash

# Script para verificar y corregir el Transit Gateway Attachment de la cuenta Prod

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Verificando Transit Gateway Attachment en la cuenta Prod ===${NC}"

# Cambiar al perfil de Prod
export AWS_PROFILE=prod
echo -e "${YELLOW}Usando perfil AWS: $AWS_PROFILE${NC}"

# Obtener ID de la VPC de Prod
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=vpc-prod" --query "Vpcs[0].VpcId" --output text)
echo -e "${BLUE}VPC ID de Prod: ${GREEN}$VPC_ID${NC}"

# Obtener ID del Transit Gateway desde la cuenta de Operaciones
export AWS_PROFILE=operaciones
TGW_ID=$(aws ec2 describe-transit-gateways --filters "Name=tag:Name,Values=tgw-multi-account" --query "TransitGateways[0].TransitGatewayId" --output text)
echo -e "${BLUE}Transit Gateway ID: ${GREEN}$TGW_ID${NC}"

# Volver al perfil de Prod
export AWS_PROFILE=prod

# Verificar si existe el attachment
ATTACHMENT_ID=$(aws ec2 describe-transit-gateway-vpc-attachments --filters "Name=vpc-id,Values=$VPC_ID" "Name=transit-gateway-id,Values=$TGW_ID" --query "TransitGatewayVpcAttachments[0].TransitGatewayAttachmentId" --output text)

if [ "$ATTACHMENT_ID" == "None" ] || [ -z "$ATTACHMENT_ID" ]; then
    echo -e "${RED}No se encontró el Transit Gateway Attachment para la VPC de Prod.${NC}"
    echo -e "${YELLOW}Creando nuevo attachment...${NC}"
    
    # Obtener IDs de las subnets
    SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].SubnetId" --output json | jq -r 'join(" ")')
    echo -e "${BLUE}Subnet IDs: ${GREEN}$SUBNET_IDS${NC}"
    
    # Crear el attachment manualmente
    ATTACHMENT_ID=$(aws ec2 create-transit-gateway-vpc-attachment \
        --transit-gateway-id $TGW_ID \
        --vpc-id $VPC_ID \
        --subnet-ids $SUBNET_IDS \
        --options "ApplianceModeSupport=enable,DnsSupport=enable" \
        --tag-specifications "ResourceType=transit-gateway-attachment,Tags=[{Key=Name,Value=tgw-attachment-prod}]" \
        --query "TransitGatewayVpcAttachment.TransitGatewayAttachmentId" \
        --output text)
    
    echo -e "${GREEN}Nuevo Transit Gateway Attachment creado: $ATTACHMENT_ID${NC}"
    
    # Esperar a que el attachment esté disponible
    echo -e "${YELLOW}Esperando a que el attachment esté disponible...${NC}"
    aws ec2 wait transit-gateway-vpc-attachment-available --transit-gateway-attachment-ids $ATTACHMENT_ID
    echo -e "${GREEN}Transit Gateway Attachment está disponible.${NC}"
else
    echo -e "${GREEN}Transit Gateway Attachment encontrado: $ATTACHMENT_ID${NC}"
    
    # Verificar el estado del attachment
    STATE=$(aws ec2 describe-transit-gateway-vpc-attachments --transit-gateway-attachment-ids $ATTACHMENT_ID --query "TransitGatewayVpcAttachments[0].State" --output text)
    echo -e "${BLUE}Estado del attachment: ${GREEN}$STATE${NC}"
    
    if [ "$STATE" != "available" ]; then
        echo -e "${YELLOW}El attachment no está disponible. Estado actual: $STATE${NC}"
        echo -e "${YELLOW}Esperando a que el attachment esté disponible...${NC}"
        aws ec2 wait transit-gateway-vpc-attachment-available --transit-gateway-attachment-ids $ATTACHMENT_ID
        echo -e "${GREEN}Transit Gateway Attachment está disponible.${NC}"
    fi
fi

# Verificar y actualizar las tablas de ruteo
echo -e "${BLUE}=== Verificando tablas de ruteo ===${NC}"

# Obtener ID de la tabla de ruteo de la VPC de Prod
RT_ID=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=rt-prod" --query "RouteTables[0].RouteTableId" --output text)
echo -e "${BLUE}ID de la tabla de ruteo de Prod: ${GREEN}$RT_ID${NC}"

# Verificar si existen las rutas hacia las VPCs de Operaciones
echo -e "${YELLOW}Verificando rutas hacia las VPCs de Operaciones...${NC}"

# Obtener CIDRs de las VPCs de Operaciones
export AWS_PROFILE=operaciones
VPC_CIDR_DEV=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=vpc-operaciones-dev" --query "Vpcs[0].CidrBlock" --output text)
VPC_CIDR_STAGE=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=vpc-operaciones-stage" --query "Vpcs[0].CidrBlock" --output text)
VPC_CIDR_PROD=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=vpc-operaciones-prod" --query "Vpcs[0].CidrBlock" --output text)

# Volver al perfil de Prod
export AWS_PROFILE=prod

# Función para verificar y crear una ruta si no existe
check_and_create_route() {
    local rt_id=$1
    local destination_cidr=$2
    local tgw_id=$3
    local description=$4
    
    # Verificar si la ruta existe
    ROUTE_EXISTS=$(aws ec2 describe-route-tables --route-table-ids $rt_id --query "RouteTables[0].Routes[?DestinationCidrBlock=='$destination_cidr'].TransitGatewayId" --output text)
    
    if [ -z "$ROUTE_EXISTS" ]; then
        echo -e "${YELLOW}Creando ruta hacia $description ($destination_cidr)...${NC}"
        aws ec2 create-route --route-table-id $rt_id --destination-cidr-block $destination_cidr --transit-gateway-id $tgw_id
        echo -e "${GREEN}Ruta creada.${NC}"
    else
        echo -e "${GREEN}La ruta hacia $description ($destination_cidr) ya existe.${NC}"
    fi
}

# Verificar y crear rutas si es necesario
check_and_create_route $RT_ID $VPC_CIDR_DEV $TGW_ID "VPC Operaciones Dev"
check_and_create_route $RT_ID $VPC_CIDR_STAGE $TGW_ID "VPC Operaciones Stage"
check_and_create_route $RT_ID $VPC_CIDR_PROD $TGW_ID "VPC Operaciones Prod"

echo -e "${GREEN}=== Verificación y corrección del Transit Gateway Attachment completada ===${NC}"
