#!/bin/bash

# Colores para mejor visualización
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Corrigiendo estado de Terraform para reglas de seguridad duplicadas ===${NC}"

# Eliminar las reglas de seguridad del estado de Terraform
echo -e "${YELLOW}Eliminando reglas de seguridad del estado de Terraform...${NC}"

# Obtener todas las reglas de seguridad en el estado
RULES=$(terraform state list | grep aws_security_group_rule)

if [ -z "$RULES" ]; then
    echo -e "${YELLOW}No se encontraron reglas de seguridad en el estado de Terraform${NC}"
else
    echo -e "${BLUE}Reglas encontradas:${NC}"
    echo "$RULES"
    
    # Eliminar cada regla del estado
    echo -e "${YELLOW}Eliminando reglas...${NC}"
    for rule in $RULES; do
        echo -e "Eliminando $rule..."
        terraform state rm "$rule"
    done
    
    echo -e "${GREEN}Reglas eliminadas correctamente${NC}"
fi

echo -e "${GREEN}=== Corrección del estado de Terraform completada ===${NC}"
echo -e "${YELLOW}Ahora puede ejecutar 'terraform apply' nuevamente para crear las reglas correctamente${NC}"
