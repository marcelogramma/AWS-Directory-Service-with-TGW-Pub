#!/bin/bash

# Cargar variables de entorno desde el archivo .env
if [ -f .env ]; then
  echo "Cargando variables de entorno desde .env..."
  export $(grep -v '^#' .env | xargs)
else
  echo "Error: Archivo .env no encontrado"
  exit 1
fi

# Obtener el ID del Transit Gateway
TGW_ID=$(terraform output transit_gateway_id | tr -d '"')
echo "Transit Gateway ID: $TGW_ID"

# Configurar credenciales de AWS para cada cuenta
#mkdir -p ~/.aws

#cat > ~/.aws/credentials << EOF
#[operaciones]
#aws_access_key_id = $AWS_ACCESS_KEY_ID_OPERACIONES
#aws_secret_access_key = $AWS_SECRET_ACCESS_KEY_OPERACIONES

#[dev]
#aws_access_key_id = $AWS_ACCESS_KEY_ID_DEV
#aws_secret_access_key = $AWS_SECRET_ACCESS_KEY_DEV

#[stage]
#aws_access_key_id = $AWS_ACCESS_KEY_ID_STAGE
#aws_secret_access_key = $AWS_SECRET_ACCESS_KEY_STAGE

#[prod]
#aws_access_key_id = $AWS_ACCESS_KEY_ID_PROD
#aws_secret_access_key = $AWS_SECRET_ACCESS_KEY_PROD
#EOF

#chmod 600 ~/.aws/credentials

# Obtener IDs de las tablas de rutas
DEV_RT_ID=$(terraform state show module.dev.aws_route_table.rt_dev | grep "id" | head -1 | awk '{print $3}' | tr -d '"')
STAGE_RT_ID=$(terraform state show module.stage.aws_route_table.rt_stage | grep "id" | head -1 | awk '{print $3}' | tr -d '"')
PROD_RT_ID=$(terraform state show module.prod.aws_route_table.rt_prod | grep "id" | head -1 | awk '{print $3}' | tr -d '"')

echo "Dev Route Table ID: $DEV_RT_ID"
echo "Stage Route Table ID: $STAGE_RT_ID"
echo "Prod Route Table ID: $PROD_RT_ID"

# Crear rutas manualmente usando AWS CLI
echo "Creando rutas para la cuenta DEV..."
aws ec2 create-route --profile dev --route-table-id $DEV_RT_ID --destination-cidr-block 10.0.0.0/16 --transit-gateway-id $TGW_ID
aws ec2 create-route --profile dev --route-table-id $DEV_RT_ID --destination-cidr-block 10.1.0.0/16 --transit-gateway-id $TGW_ID
aws ec2 create-route --profile dev --route-table-id $DEV_RT_ID --destination-cidr-block 10.2.0.0/16 --transit-gateway-id $TGW_ID

echo "Creando rutas para la cuenta STAGE..."
aws ec2 create-route --profile stage --route-table-id $STAGE_RT_ID --destination-cidr-block 10.0.0.0/16 --transit-gateway-id $TGW_ID
aws ec2 create-route --profile stage --route-table-id $STAGE_RT_ID --destination-cidr-block 10.1.0.0/16 --transit-gateway-id $TGW_ID
aws ec2 create-route --profile stage --route-table-id $STAGE_RT_ID --destination-cidr-block 10.2.0.0/16 --transit-gateway-id $TGW_ID

echo "Creando rutas para la cuenta PROD..."
aws ec2 create-route --profile prod --route-table-id $PROD_RT_ID --destination-cidr-block 10.0.0.0/16 --transit-gateway-id $TGW_ID
aws ec2 create-route --profile prod --route-table-id $PROD_RT_ID --destination-cidr-block 10.1.0.0/16 --transit-gateway-id $TGW_ID
aws ec2 create-route --profile prod --route-table-id $PROD_RT_ID --destination-cidr-block 10.2.0.0/16 --transit-gateway-id $TGW_ID

echo "Proceso completado."
