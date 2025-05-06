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

# Obtener IDs de las VPCs
echo "Obteniendo IDs de las VPCs..."
VPC_OPERACIONES_DEV=$(terraform output -json vpc_ids | jq -r '.operaciones_dev')
VPC_OPERACIONES_STAGE=$(terraform output -json vpc_ids | jq -r '.operaciones_stage')
VPC_OPERACIONES_PROD=$(terraform output -json vpc_ids | jq -r '.operaciones_prod')
VPC_DEV=$(terraform output -json vpc_ids | jq -r '.dev')
VPC_STAGE=$(terraform output -json vpc_ids | jq -r '.stage')
VPC_PROD=$(terraform output -json vpc_ids | jq -r '.prod')

echo "VPC Operaciones $ACCOUNT_NAME_DEV: $VPC_OPERACIONES_DEV"
echo "VPC Operaciones $ACCOUNT_NAME_STAGE: $VPC_OPERACIONES_STAGE"
echo "VPC Operaciones $ACCOUNT_NAME_PROD: $VPC_OPERACIONES_PROD"
echo "VPC $ACCOUNT_NAME_DEV: $VPC_DEV"
echo "VPC $ACCOUNT_NAME_STAGE: $VPC_STAGE"
echo "VPC $ACCOUNT_NAME_PROD: $VPC_PROD"

# Crear CloudShell scripts para cada cuenta
echo "Creando scripts de CloudShell para pruebas de conectividad..."

# Script para cuenta Operaciones
cat > cloudshell_${ACCOUNT_NAME_OPERACIONES}.sh << EOF
#!/bin/bash
echo "=== Test de Conectividad desde CloudShell en cuenta ${ACCOUNT_NAME_OPERACIONES^^} ==="
echo "Probando conectividad a VPC Operaciones Dev ($VPC_OPERACIONES_DEV)..."
aws ec2 describe-vpcs --vpc-ids $VPC_OPERACIONES_DEV --region $AWS_REGION --output json

echo "Probando conectividad a VPC Operaciones Stage ($VPC_OPERACIONES_STAGE)..."
aws ec2 describe-vpcs --vpc-ids $VPC_OPERACIONES_STAGE --region $AWS_REGION --output json

echo "Probando conectividad a VPC Operaciones Prod ($VPC_OPERACIONES_PROD)..."
aws ec2 describe-vpcs --vpc-ids $VPC_OPERACIONES_PROD --region $AWS_REGION --output json

echo "Probando conectividad a Directory Services..."
aws ds describe-directories --region $AWS_REGION --output json

echo "Probando conectividad a Transit Gateway..."
aws ec2 describe-transit-gateways --region $AWS_REGION --output json

echo "Probando conectividad a Transit Gateway Attachments..."
aws ec2 describe-transit-gateway-attachments --region $AWS_REGION --output json
EOF

# Script para cuenta Dev
cat > cloudshell_${ACCOUNT_NAME_DEV}.sh << EOF
#!/bin/bash
echo "=== Test de Conectividad desde CloudShell en cuenta ${ACCOUNT_NAME_DEV^^} ==="
echo "Probando conectividad a VPC Dev ($VPC_DEV)..."
aws ec2 describe-vpcs --vpc-ids $VPC_DEV --region $AWS_REGION --output json

echo "Probando conectividad a Transit Gateway Attachment..."
aws ec2 describe-transit-gateway-attachments --region $AWS_REGION --output json

echo "Probando rutas hacia VPCs de Operaciones..."
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_DEV" --region $AWS_REGION --output json
EOF

# Script para cuenta Stage
cat > cloudshell_${ACCOUNT_NAME_STAGE}.sh << EOF
#!/bin/bash
echo "=== Test de Conectividad desde CloudShell en cuenta ${ACCOUNT_NAME_STAGE^^} ==="
echo "Probando conectividad a VPC Stage ($VPC_STAGE)..."
aws ec2 describe-vpcs --vpc-ids $VPC_STAGE --region $AWS_REGION --output json

echo "Probando conectividad a Transit Gateway Attachment..."
aws ec2 describe-transit-gateway-attachments --region $AWS_REGION --output json

echo "Probando rutas hacia VPCs de Operaciones..."
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_STAGE" --region $AWS_REGION --output json
EOF

# Script para cuenta Prod
cat > cloudshell_${ACCOUNT_NAME_PROD}.sh << EOF
#!/bin/bash
echo "=== Test de Conectividad desde CloudShell en cuenta ${ACCOUNT_NAME_PROD^^} ==="
echo "Probando conectividad a VPC Prod ($VPC_PROD)..."
aws ec2 describe-vpcs --vpc-ids $VPC_PROD --region $AWS_REGION --output json

echo "Probando conectividad a Transit Gateway Attachment..."
aws ec2 describe-transit-gateway-attachments --region $AWS_REGION --output json

echo "Probando rutas hacia VPCs de Operaciones..."
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_PROD" --region $AWS_REGION --output json
EOF

chmod +x cloudshell_*.sh

# Ejecutar pruebas en CloudShell para cada cuenta
echo "Para ejecutar las pruebas de conectividad, sigue estos pasos:"
echo ""
echo "1. Para la cuenta ${ACCOUNT_NAME_OPERACIONES^^}:"
echo "   - Abre CloudShell en la consola AWS de la cuenta ${ACCOUNT_NAME_OPERACIONES^^}"
echo "   - Sube el archivo cloudshell_${ACCOUNT_NAME_OPERACIONES}.sh"
echo "   - Ejecuta: chmod +x cloudshell_${ACCOUNT_NAME_OPERACIONES}.sh && ./cloudshell_${ACCOUNT_NAME_OPERACIONES}.sh"
echo ""
echo "2. Para la cuenta ${ACCOUNT_NAME_DEV^^}:"
echo "   - Abre CloudShell en la consola AWS de la cuenta ${ACCOUNT_NAME_DEV^^}"
echo "   - Sube el archivo cloudshell_${ACCOUNT_NAME_DEV}.sh"
echo "   - Ejecuta: chmod +x cloudshell_${ACCOUNT_NAME_DEV}.sh && ./cloudshell_${ACCOUNT_NAME_DEV}.sh"
echo ""
echo "3. Para la cuenta ${ACCOUNT_NAME_STAGE^^}:"
echo "   - Abre CloudShell en la consola AWS de la cuenta ${ACCOUNT_NAME_STAGE^^}"
echo "   - Sube el archivo cloudshell_${ACCOUNT_NAME_STAGE}.sh"
echo "   - Ejecuta: chmod +x cloudshell_${ACCOUNT_NAME_STAGE}.sh && ./cloudshell_${ACCOUNT_NAME_STAGE}.sh"
echo ""
echo "4. Para la cuenta ${ACCOUNT_NAME_PROD^^}:"
echo "   - Abre CloudShell en la consola AWS de la cuenta ${ACCOUNT_NAME_PROD^^}"
echo "   - Sube el archivo cloudshell_${ACCOUNT_NAME_PROD}.sh"
echo "   - Ejecuta: chmod +x cloudshell_${ACCOUNT_NAME_PROD}.sh && ./cloudshell_${ACCOUNT_NAME_PROD}.sh"
echo ""
echo "Scripts de CloudShell generados correctamente."
