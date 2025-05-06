#!/bin/bash

# Script para probar la conectividad del Transit Gateway Attachment de la cuenta Prod

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Probando conectividad del Transit Gateway Attachment de Prod ===${NC}"

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

# Obtener IDs de los servicios de directorio
DIR_DEV_ID=$(aws ds describe-directories --query "DirectoryDescriptions[?Name=='dev.local'].DirectoryId" --output text)
DIR_STAGE_ID=$(aws ds describe-directories --query "DirectoryDescriptions[?Name=='stage.local'].DirectoryId" --output text)
DIR_PROD_ID=$(aws ds describe-directories --query "DirectoryDescriptions[?Name=='prod.local'].DirectoryId" --output text)

echo -e "${BLUE}Directory Service Dev ID: ${GREEN}$DIR_DEV_ID${NC}"
echo -e "${BLUE}Directory Service Stage ID: ${GREEN}$DIR_STAGE_ID${NC}"
echo -e "${BLUE}Directory Service Prod ID: ${GREEN}$DIR_PROD_ID${NC}"

# Volver al perfil de Prod
export AWS_PROFILE=prod

# Verificar el Transit Gateway Attachment
ATTACHMENT_ID=$(aws ec2 describe-transit-gateway-vpc-attachments --filters "Name=vpc-id,Values=$VPC_ID" "Name=transit-gateway-id,Values=$TGW_ID" --query "TransitGatewayVpcAttachments[0].TransitGatewayAttachmentId" --output text)

if [ "$ATTACHMENT_ID" == "None" ] || [ -z "$ATTACHMENT_ID" ]; then
    echo -e "${RED}No se encontró el Transit Gateway Attachment para la VPC de Prod.${NC}"
    exit 1
else
    echo -e "${GREEN}Transit Gateway Attachment encontrado: $ATTACHMENT_ID${NC}"
    
    # Verificar el estado del attachment
    STATE=$(aws ec2 describe-transit-gateway-vpc-attachments --transit-gateway-attachment-ids $ATTACHMENT_ID --query "TransitGatewayVpcAttachments[0].State" --output text)
    echo -e "${BLUE}Estado del attachment: ${GREEN}$STATE${NC}"
    
    if [ "$STATE" != "available" ]; then
        echo -e "${RED}El attachment no está disponible. Estado actual: $STATE${NC}"
        exit 1
    fi
fi

# Crear una instancia EC2 temporal para probar la conectividad
echo -e "${YELLOW}Creando instancia EC2 temporal para pruebas...${NC}"

# Obtener la última AMI de Amazon Linux 2
AMI_ID=$(aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" "Name=state,Values=available" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)
echo -e "${BLUE}AMI ID: ${GREEN}$AMI_ID${NC}"

# Obtener la primera subnet de la VPC
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[0].SubnetId" --output text)
echo -e "${BLUE}Subnet ID: ${GREEN}$SUBNET_ID${NC}"

# Crear un grupo de seguridad para la instancia
SG_NAME="test-tgw-connectivity-$(date +%s)"
SG_ID=$(aws ec2 create-security-group --group-name $SG_NAME --description "Grupo de seguridad temporal para pruebas de conectividad TGW" --vpc-id $VPC_ID --query "GroupId" --output text)
echo -e "${BLUE}Security Group ID: ${GREEN}$SG_ID${NC}"

# Permitir SSH desde cualquier lugar (solo para pruebas)
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0

# Crear un key pair temporal
KEY_NAME="key-test-tgw-connectivity-$(date +%s)"
KEY_FILE="/tmp/$KEY_NAME.pem"
aws ec2 create-key-pair --key-name $KEY_NAME --query "KeyMaterial" --output text > $KEY_FILE
chmod 400 $KEY_FILE
echo -e "${BLUE}Key pair creado: ${GREEN}$KEY_NAME${NC}"

# Crear la instancia
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --key-name $KEY_NAME \
    --security-group-ids $SG_ID \
    --subnet-id $SUBNET_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=test-tgw-connectivity}]" \
    --query "Instances[0].InstanceId" \
    --output text)
echo -e "${BLUE}Instance ID: ${GREEN}$INSTANCE_ID${NC}"

# Esperar a que la instancia esté en ejecución
echo -e "${YELLOW}Esperando a que la instancia esté en ejecución...${NC}"
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo -e "${GREEN}La instancia está en ejecución.${NC}"

# Obtener la IP pública de la instancia
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
echo -e "${BLUE}IP pública de la instancia: ${GREEN}$PUBLIC_IP${NC}"

# Esperar un poco más para asegurarse de que la instancia esté lista
echo -e "${YELLOW}Esperando 30 segundos adicionales para que la instancia esté completamente lista...${NC}"
sleep 30

# Probar la conectividad a los servicios de directorio
echo -e "${YELLOW}Probando conectividad a los servicios de directorio...${NC}"

# Obtener las direcciones DNS de los servicios de directorio
export AWS_PROFILE=operaciones
DIR_DEV_DNS=$(aws ds describe-directories --directory-ids $DIR_DEV_ID --query "DirectoryDescriptions[0].DnsIpAddrs" --output text)
DIR_STAGE_DNS=$(aws ds describe-directories --directory-ids $DIR_STAGE_ID --query "DirectoryDescriptions[0].DnsIpAddrs" --output text)
DIR_PROD_DNS=$(aws ds describe-directories --directory-ids $DIR_PROD_ID --query "DirectoryDescriptions[0].DnsIpAddrs" --output text)

# Volver al perfil de Prod
export AWS_PROFILE=prod

# Función para probar la conectividad a una dirección IP
test_connectivity() {
    local ip=$1
    local description=$2
    
    echo -e "${YELLOW}Probando conectividad a $description ($ip)...${NC}"
    
    # Usar SSH para ejecutar un comando ping en la instancia
    PING_RESULT=$(ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i $KEY_FILE ec2-user@$PUBLIC_IP "ping -c 3 -W 2 $ip" 2>&1)
    
    if [[ $PING_RESULT == *"3 received"* ]]; then
        echo -e "${GREEN}Conectividad exitosa a $description ($ip).${NC}"
        return 0
    else
        echo -e "${RED}No se pudo conectar a $description ($ip).${NC}"
        echo -e "${RED}Resultado: $PING_RESULT${NC}"
        return 1
    fi
}

# Probar la conectividad a cada servidor DNS de los servicios de directorio
for IP in $DIR_DEV_DNS; do
    test_connectivity $IP "Directory Service Dev DNS"
done

for IP in $DIR_STAGE_DNS; do
    test_connectivity $IP "Directory Service Stage DNS"
done

for IP in $DIR_PROD_DNS; do
    test_connectivity $IP "Directory Service Prod DNS"
done

# Limpiar recursos
echo -e "${YELLOW}Limpiando recursos temporales...${NC}"

# Terminar la instancia
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
echo -e "${GREEN}Instancia terminada.${NC}"

# Esperar a que la instancia se termine
echo -e "${YELLOW}Esperando a que la instancia se termine...${NC}"
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
echo -e "${GREEN}La instancia ha sido terminada.${NC}"

# Eliminar el grupo de seguridad
aws ec2 delete-security-group --group-id $SG_ID
echo -e "${GREEN}Grupo de seguridad eliminado.${NC}"

# Eliminar el key pair
aws ec2 delete-key-pair --key-name $KEY_NAME
rm -f $KEY_FILE
echo -e "${GREEN}Key pair eliminado.${NC}"

echo -e "${GREEN}=== Prueba de conectividad completada ===${NC}"
