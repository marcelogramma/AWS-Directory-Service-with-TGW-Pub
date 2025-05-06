#!/bin/bash

# Colores para mejor visualización
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Corrigiendo reglas de seguridad duplicadas ===${NC}"

# Obtener el estado actual de Terraform
echo -e "${YELLOW}Obteniendo el estado actual de Terraform...${NC}"
terraform state list | grep aws_security_group_rule > sg_rules.txt

# Contar cuántas reglas hay para cada grupo de seguridad
echo -e "${BLUE}Analizando reglas duplicadas...${NC}"

# Obtener los IDs de los security groups
DEV_SG_ID=$(terraform state show aws_directory_service_directory.directory_dev | grep security_group_id | awk '{print $3}' | tr -d '"')
STAGE_SG_ID=$(terraform state show aws_directory_service_directory.directory_stage | grep security_group_id | awk '{print $3}' | tr -d '"')
PROD_SG_ID=$(terraform state show aws_directory_service_directory.directory_prod | grep security_group_id | awk '{print $3}' | tr -d '"')

echo -e "${BLUE}Security Group IDs:${NC}"
echo -e "Dev: ${GREEN}$DEV_SG_ID${NC}"
echo -e "Stage: ${GREEN}$STAGE_SG_ID${NC}"
echo -e "Prod: ${GREEN}$PROD_SG_ID${NC}"

# Eliminar reglas duplicadas del estado de Terraform
echo -e "${YELLOW}Eliminando reglas duplicadas del estado de Terraform...${NC}"

# Función para eliminar reglas duplicadas para un grupo de seguridad específico
remove_duplicates() {
    local sg_name=$1
    local sg_id=$2
    
    echo -e "${BLUE}Procesando reglas para $sg_name (ID: $sg_id)...${NC}"
    
    # Obtener todas las reglas para este security group
    grep "$sg_name" sg_rules.txt > "${sg_name}_rules.txt"
    
    # Crear un archivo para reglas a mantener
    > "${sg_name}_keep.txt"
    
    # Procesar cada tipo de regla (dns, kerberos, ldap, etc.)
    for rule_type in dns dns_udp kerberos kerberos_udp ldap ldap_udp smb ldaps kerberos_pwd kerberos_pwd_udp global_catalog ntp rpc ephemeral ephemeral_udp; do
        # Buscar reglas de este tipo
        grep "\[\"$rule_type\"\]" "${sg_name}_rules.txt" > "temp_rules.txt"
        
        # Si hay más de una regla de este tipo, mantener solo la primera
        if [ $(wc -l < "temp_rules.txt") -gt 1 ]; then
            head -n 1 "temp_rules.txt" >> "${sg_name}_keep.txt"
            tail -n +2 "temp_rules.txt" > "temp_remove.txt"
            
            # Eliminar las reglas duplicadas
            while read rule; do
                echo -e "${RED}Eliminando regla duplicada: $rule${NC}"
                terraform state rm "$rule"
            done < "temp_remove.txt"
        else
            cat "temp_rules.txt" >> "${sg_name}_keep.txt"
        fi
    done
    
    echo -e "${GREEN}Reglas mantenidas para $sg_name:${NC}"
    cat "${sg_name}_keep.txt"
}

# Procesar cada grupo de seguridad
remove_duplicates "directory_dev_rules" "$DEV_SG_ID"
remove_duplicates "directory_stage_rules" "$STAGE_SG_ID"
remove_duplicates "directory_prod_rules" "$PROD_SG_ID"

# Limpiar archivos temporales
rm -f sg_rules.txt *_rules.txt *_keep.txt temp_rules.txt temp_remove.txt

echo -e "${GREEN}=== Corrección de reglas de seguridad duplicadas completada ===${NC}"
echo -e "${YELLOW}Ahora puede ejecutar 'terraform apply' nuevamente${NC}"
