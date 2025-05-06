#!/bin/bash

# Colores para mejor visualización
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Corrigiendo reglas de seguridad duplicadas ===${NC}"

# Obtener los IDs de los security groups
echo -e "${YELLOW}Obteniendo IDs de los security groups...${NC}"

# Usar AWS CLI para obtener los security groups
DEV_SG_ID=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=directory-dev" --query "SecurityGroups[0].GroupId" --output text)
STAGE_SG_ID=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=directory-stage" --query "SecurityGroups[0].GroupId" --output text)
PROD_SG_ID=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=directory-prod" --query "SecurityGroups[0].GroupId" --output text)

echo -e "${BLUE}Security Group IDs:${NC}"
echo -e "Dev: ${GREEN}$DEV_SG_ID${NC}"
echo -e "Stage: ${GREEN}$STAGE_SG_ID${NC}"
echo -e "Prod: ${GREEN}$PROD_SG_ID${NC}"

# Eliminar todas las reglas de ingreso existentes
echo -e "${YELLOW}Eliminando reglas de ingreso existentes...${NC}"

# Función para eliminar todas las reglas de ingreso de un security group
remove_ingress_rules() {
    local sg_name=$1
    local sg_id=$2
    
    if [ -z "$sg_id" ] || [ "$sg_id" == "None" ]; then
        echo -e "${RED}No se encontró el ID para $sg_name${NC}"
        return
    fi
    
    echo -e "${BLUE}Eliminando reglas de ingreso para $sg_name (ID: $sg_id)...${NC}"
    
    # Obtener todas las reglas de ingreso
    RULES=$(aws ec2 describe-security-groups --group-ids $sg_id --query "SecurityGroups[0].IpPermissions" --output json)
    
    if [ "$RULES" == "[]" ]; then
        echo -e "${YELLOW}No hay reglas de ingreso para eliminar en $sg_name${NC}"
        return
    fi
    
    # Eliminar todas las reglas de ingreso
    aws ec2 revoke-security-group-ingress --group-id $sg_id --ip-permissions "$RULES"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Reglas de ingreso eliminadas correctamente para $sg_name${NC}"
    else
        echo -e "${RED}Error al eliminar reglas de ingreso para $sg_name${NC}"
    fi
}

# Eliminar reglas de ingreso para cada security group
remove_ingress_rules "Directory Dev" "$DEV_SG_ID"
remove_ingress_rules "Directory Stage" "$STAGE_SG_ID"
remove_ingress_rules "Directory Prod" "$PROD_SG_ID"

echo -e "${GREEN}=== Corrección de reglas de seguridad completada ===${NC}"
echo -e "${YELLOW}Ahora puede ejecutar 'terraform apply' nuevamente para crear las reglas correctamente${NC}"
