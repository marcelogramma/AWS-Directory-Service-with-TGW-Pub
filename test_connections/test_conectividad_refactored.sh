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

# Directorio para almacenar los resultados de las pruebas
RESULTS_DIR="connectivity_test_results"
mkdir -p $RESULTS_DIR

# Obtener IDs de las VPCs
echo "Obteniendo IDs de las VPCs..."
VPC_DEV=$(terraform output -json vpc_ids | jq -r '.dev')
VPC_STAGE=$(terraform output -json vpc_ids | jq -r '.stage')
VPC_PROD=$(terraform output -json vpc_ids | jq -r '.prod')

echo "VPC $ACCOUNT_NAME_DEV: $VPC_DEV"
echo "VPC $ACCOUNT_NAME_STAGE: $VPC_STAGE"
echo "VPC $ACCOUNT_NAME_PROD: $VPC_PROD"

# Obtener IDs de los Directory Services
echo "Obteniendo IDs de los Directory Services..."
DIR_DEV=$(terraform output -json directory_service_ids | jq -r '.dev')
DIR_STAGE=$(terraform output -json directory_service_ids | jq -r '.stage')
DIR_PROD=$(terraform output -json directory_service_ids | jq -r '.prod')

echo "Directory Service $ACCOUNT_NAME_DEV: $DIR_DEV"
echo "Directory Service $ACCOUNT_NAME_STAGE: $DIR_STAGE"
echo "Directory Service $ACCOUNT_NAME_PROD: $DIR_PROD"

# Obtener IPs de los Directory Services
echo "Obteniendo IPs de los Directory Services..."
DNS_IPS_DEV=$(aws ds describe-directories --directory-ids $DIR_DEV --profile $ACCOUNT_NAME_OPERACIONES --region $AWS_REGION --query "DirectoryDescriptions[0].DnsIpAddrs" --output json)
DNS_IPS_STAGE=$(aws ds describe-directories --directory-ids $DIR_STAGE --profile $ACCOUNT_NAME_OPERACIONES --region $AWS_REGION --query "DirectoryDescriptions[0].DnsIpAddrs" --output json)
DNS_IPS_PROD=$(aws ds describe-directories --directory-ids $DIR_PROD --profile $ACCOUNT_NAME_OPERACIONES --region $AWS_REGION --query "DirectoryDescriptions[0].DnsIpAddrs" --output json)

# Extraer la primera IP de cada Directory Service
IP_DIR_DEV=$(echo $DNS_IPS_DEV | jq -r '.[0]')
IP_DIR_STAGE=$(echo $DNS_IPS_STAGE | jq -r '.[0]')
IP_DIR_PROD=$(echo $DNS_IPS_PROD | jq -r '.[0]')

echo "IP Directory Service $ACCOUNT_NAME_DEV: $IP_DIR_DEV"
echo "IP Directory Service $ACCOUNT_NAME_STAGE: $IP_DIR_STAGE"
echo "IP Directory Service $ACCOUNT_NAME_PROD: $IP_DIR_PROD"

# Obtener IDs de las subnets públicas
echo "Obteniendo IDs de las subnets públicas..."
SUBNET_DEV=$(aws ec2 describe-subnets --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --filters "Name=vpc-id,Values=$VPC_DEV" "Name=tag:Name,Values=*public*" "Name=map-public-ip-on-launch,Values=true" --query "Subnets[0].SubnetId" --output text)
SUBNET_STAGE=$(aws ec2 describe-subnets --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --filters "Name=vpc-id,Values=$VPC_STAGE" "Name=tag:Name,Values=*public*" "Name=map-public-ip-on-launch,Values=true" --query "Subnets[0].SubnetId" --output text)
SUBNET_PROD=$(aws ec2 describe-subnets --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --filters "Name=vpc-id,Values=$VPC_PROD" "Name=tag:Name,Values=*public*" "Name=map-public-ip-on-launch,Values=true" --query "Subnets[0].SubnetId" --output text)

# Verificar que se encontraron subnets públicas
if [ -z "$SUBNET_DEV" ] || [ "$SUBNET_DEV" == "None" ]; then
  echo "No se encontró subnet pública para Dev. Buscando cualquier subnet..."
  SUBNET_DEV=$(aws ec2 describe-subnets --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --filters "Name=vpc-id,Values=$VPC_DEV" --query "Subnets[0].SubnetId" --output text)
  echo "Configurando subnet para asignar IP pública automáticamente..."
  aws ec2 modify-subnet-attribute --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --subnet-id $SUBNET_DEV --map-public-ip-on-launch
fi

if [ -z "$SUBNET_STAGE" ] || [ "$SUBNET_STAGE" == "None" ]; then
  echo "No se encontró subnet pública para Stage. Buscando cualquier subnet..."
  SUBNET_STAGE=$(aws ec2 describe-subnets --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --filters "Name=vpc-id,Values=$VPC_STAGE" --query "Subnets[0].SubnetId" --output text)
  echo "Configurando subnet para asignar IP pública automáticamente..."
  aws ec2 modify-subnet-attribute --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --subnet-id $SUBNET_STAGE --map-public-ip-on-launch
fi

if [ -z "$SUBNET_PROD" ] || [ "$SUBNET_PROD" == "None" ]; then
  echo "No se encontró subnet pública para Prod. Buscando cualquier subnet..."
  SUBNET_PROD=$(aws ec2 describe-subnets --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --filters "Name=vpc-id,Values=$VPC_PROD" --query "Subnets[0].SubnetId" --output text)
  echo "Configurando subnet para asignar IP pública automáticamente..."
  aws ec2 modify-subnet-attribute --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --subnet-id $SUBNET_PROD --map-public-ip-on-launch
fi

echo "Subnet $ACCOUNT_NAME_DEV: $SUBNET_DEV"
echo "Subnet $ACCOUNT_NAME_STAGE: $SUBNET_STAGE"
echo "Subnet $ACCOUNT_NAME_PROD: $SUBNET_PROD"

# Crear grupos de seguridad para las instancias de prueba
echo "Creando grupos de seguridad..."

# Grupo de seguridad para Dev
SG_DEV=$(aws ec2 create-security-group --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --group-name "test-connectivity-sg-$ACCOUNT_NAME_DEV" --description "Security group for testing connectivity" --vpc-id $VPC_DEV --query "GroupId" --output text)
aws ec2 authorize-security-group-ingress --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --group-id $SG_DEV --protocol icmp --port -1 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --group-id $SG_DEV --protocol tcp --port 22 --cidr 0.0.0.0/0

# Grupo de seguridad para Stage
SG_STAGE=$(aws ec2 create-security-group --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --group-name "test-connectivity-sg-$ACCOUNT_NAME_STAGE" --description "Security group for testing connectivity" --vpc-id $VPC_STAGE --query "GroupId" --output text)
aws ec2 authorize-security-group-ingress --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --group-id $SG_STAGE --protocol icmp --port -1 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --group-id $SG_STAGE --protocol tcp --port 22 --cidr 0.0.0.0/0

# Grupo de seguridad para Prod
SG_PROD=$(aws ec2 create-security-group --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --group-name "test-connectivity-sg-$ACCOUNT_NAME_PROD" --description "Security group for testing connectivity" --vpc-id $VPC_PROD --query "GroupId" --output text)
aws ec2 authorize-security-group-ingress --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --group-id $SG_PROD --protocol icmp --port -1 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --group-id $SG_PROD --protocol tcp --port 22 --cidr 0.0.0.0/0

echo "Grupos de seguridad creados:"
echo "SG $ACCOUNT_NAME_DEV: $SG_DEV"
echo "SG $ACCOUNT_NAME_STAGE: $SG_STAGE"
echo "SG $ACCOUNT_NAME_PROD: $SG_PROD"

# Determinar la AMI a usar basada en la región
# Por defecto, usar Amazon Linux 2 AMI
AMI_ID="ami-0f88e80871fd81e91"  # Amazon Linux 2 en us-east-1

# Si la región no es us-east-1, buscar una AMI adecuada
if [ "$AWS_REGION" != "us-east-1" ]; then
  echo "Buscando AMI de Amazon Linux 2 para la región $AWS_REGION..."
  AMI_ID=$(aws ec2 describe-images --profile $ACCOUNT_NAME_DEV --region $AWS_REGION \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-2.0.*-x86_64-gp2" "Name=state,Values=available" \
    --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)
  
  if [ -z "$AMI_ID" ] || [ "$AMI_ID" == "None" ]; then
    echo "No se pudo encontrar una AMI adecuada para la región $AWS_REGION. Usando AMI por defecto."
    AMI_ID="ami-0f88e80871fd81e91"  # Volver a la AMI por defecto
  else
    echo "AMI encontrada para la región $AWS_REGION: $AMI_ID"
  fi
fi

# Crear instancias EC2 para pruebas de conectividad
echo "Creando instancias EC2 para pruebas de conectividad..."

# Crear key pair para las instancias
KEY_NAME="test-connectivity-key-$(date +%s)"
aws ec2 create-key-pair --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --key-name $KEY_NAME --query "KeyMaterial" --output text > ${KEY_NAME}-1.pem

# Crear key pairs en cada cuenta
aws ec2 create-key-pair --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --key-name $KEY_NAME --query "KeyMaterial" --output text > ${KEY_NAME}-2.pem
aws ec2 create-key-pair --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --key-name $KEY_NAME --query "KeyMaterial" --output text > ${KEY_NAME}-3.pem

# Crear instancia en Dev
INSTANCE_DEV=$(aws ec2 run-instances --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --image-id $AMI_ID --instance-type t2.micro --key-name $KEY_NAME --security-group-ids $SG_DEV --subnet-id $SUBNET_DEV --associate-public-ip-address --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=test-connectivity-$ACCOUNT_NAME_DEV}]" --query "Instances[0].InstanceId" --output text)

# Crear instancia en Stage
INSTANCE_STAGE=$(aws ec2 run-instances --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --image-id $AMI_ID --instance-type t2.micro --key-name $KEY_NAME --security-group-ids $SG_STAGE --subnet-id $SUBNET_STAGE --associate-public-ip-address --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=test-connectivity-$ACCOUNT_NAME_STAGE}]" --query "Instances[0].InstanceId" --output text)

# Crear instancia en Prod
INSTANCE_PROD=$(aws ec2 run-instances --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --image-id $AMI_ID --instance-type t2.micro --key-name $KEY_NAME --security-group-ids $SG_PROD --subnet-id $SUBNET_PROD --associate-public-ip-address --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=test-connectivity-$ACCOUNT_NAME_PROD}]" --query "Instances[0].InstanceId" --output text)

echo "Instancias creadas:"
echo "Instancia $ACCOUNT_NAME_DEV: $INSTANCE_DEV"
echo "Instancia $ACCOUNT_NAME_STAGE: $INSTANCE_STAGE"
echo "Instancia $ACCOUNT_NAME_PROD: $INSTANCE_PROD"
# Esperar a que las instancias estén en estado running
echo "Esperando a que las instancias estén en estado running..."
aws ec2 wait instance-running --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --instance-ids $INSTANCE_DEV
aws ec2 wait instance-running --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --instance-ids $INSTANCE_STAGE
aws ec2 wait instance-running --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --instance-ids $INSTANCE_PROD

# Obtener IPs privadas de las instancias
IP_DEV=$(aws ec2 describe-instances --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --instance-ids $INSTANCE_DEV --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
IP_STAGE=$(aws ec2 describe-instances --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --instance-ids $INSTANCE_STAGE --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
IP_PROD=$(aws ec2 describe-instances --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --instance-ids $INSTANCE_PROD --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)

echo "IPs privadas de las instancias:"
echo "IP $ACCOUNT_NAME_DEV: $IP_DEV"
echo "IP $ACCOUNT_NAME_STAGE: $IP_STAGE"
echo "IP $ACCOUNT_NAME_PROD: $IP_PROD"

# Crear script de prueba de conectividad para cada instancia
cat > test_${ACCOUNT_NAME_DEV}.sh << EOF
#!/bin/bash
echo "Prueba de conectividad desde ${ACCOUNT_NAME_DEV^^} ($IP_DEV) al Directory Service ${ACCOUNT_NAME_DEV^^} ($IP_DIR_DEV):"
echo "===================================================================="
ping -c 5 $IP_DIR_DEV
echo "===================================================================="
EOF

cat > test_${ACCOUNT_NAME_STAGE}.sh << EOF
#!/bin/bash
echo "Prueba de conectividad desde ${ACCOUNT_NAME_STAGE^^} ($IP_STAGE) al Directory Service ${ACCOUNT_NAME_STAGE^^} ($IP_DIR_STAGE):"
echo "===================================================================="
ping -c 5 $IP_DIR_STAGE
echo "===================================================================="
EOF

cat > test_${ACCOUNT_NAME_PROD}.sh << EOF
#!/bin/bash
echo "Prueba de conectividad desde ${ACCOUNT_NAME_PROD^^} ($IP_PROD) al Directory Service ${ACCOUNT_NAME_PROD^^} ($IP_DIR_PROD):"
echo "===================================================================="
ping -c 5 $IP_DIR_PROD
echo "===================================================================="
EOF

chmod +x test_*.sh

# Obtener IPs públicas de las instancias
echo "Esperando a que las IPs públicas estén disponibles..."
sleep 10

PUBLIC_IP_DEV=$(aws ec2 describe-instances --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --instance-ids $INSTANCE_DEV --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
PUBLIC_IP_STAGE=$(aws ec2 describe-instances --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --instance-ids $INSTANCE_STAGE --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
PUBLIC_IP_PROD=$(aws ec2 describe-instances --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --instance-ids $INSTANCE_PROD --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

# Verificar que todas las instancias tienen IPs públicas
if [ -z "$PUBLIC_IP_DEV" ] || [ "$PUBLIC_IP_DEV" == "None" ]; then
  echo "Error: La instancia de ${ACCOUNT_NAME_DEV^^} no tiene IP pública asignada."
  echo "Asignando IP elástica..."
  ELASTIC_IP_DEV=$(aws ec2 allocate-address --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --domain vpc --query "AllocationId" --output text)
  aws ec2 associate-address --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --instance-id $INSTANCE_DEV --allocation-id $ELASTIC_IP_DEV
  PUBLIC_IP_DEV=$(aws ec2 describe-addresses --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --allocation-ids $ELASTIC_IP_DEV --query "Addresses[0].PublicIp" --output text)
fi

if [ -z "$PUBLIC_IP_STAGE" ] || [ "$PUBLIC_IP_STAGE" == "None" ]; then
  echo "Error: La instancia de ${ACCOUNT_NAME_STAGE^^} no tiene IP pública asignada."
  echo "Asignando IP elástica..."
  ELASTIC_IP_STAGE=$(aws ec2 allocate-address --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --domain vpc --query "AllocationId" --output text)
  aws ec2 associate-address --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --instance-id $INSTANCE_STAGE --allocation-id $ELASTIC_IP_STAGE
  PUBLIC_IP_STAGE=$(aws ec2 describe-addresses --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --allocation-ids $ELASTIC_IP_STAGE --query "Addresses[0].PublicIp" --output text)
fi

if [ -z "$PUBLIC_IP_PROD" ] || [ "$PUBLIC_IP_PROD" == "None" ]; then
  echo "Error: La instancia de ${ACCOUNT_NAME_PROD^^} no tiene IP pública asignada."
  echo "Asignando IP elástica..."
  ELASTIC_IP_PROD=$(aws ec2 allocate-address --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --domain vpc --query "AllocationId" --output text)
  aws ec2 associate-address --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --instance-id $INSTANCE_PROD --allocation-id $ELASTIC_IP_PROD
  PUBLIC_IP_PROD=$(aws ec2 describe-addresses --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --allocation-ids $ELASTIC_IP_PROD --query "Addresses[0].PublicIp" --output text)
fi

# Cambiar permisos de la clave privada
echo "Cambiando permisos de la clave privada..."
chmod 400 *.pem

echo "IPs públicas de las instancias:"
echo "IP Pública $ACCOUNT_NAME_DEV: $PUBLIC_IP_DEV"
echo "IP Pública $ACCOUNT_NAME_STAGE: $PUBLIC_IP_STAGE"
echo "IP Pública $ACCOUNT_NAME_PROD: $PUBLIC_IP_PROD"
# Esperar a que SSH esté disponible en todas las instancias
echo "Esperando a que SSH esté disponible en todas las instancias..."
for i in {1..30}; do
  nc -z -w 5 $PUBLIC_IP_DEV 22 && nc -z -w 5 $PUBLIC_IP_STAGE 22 && nc -z -w 5 $PUBLIC_IP_PROD 22 && break
  echo "Intentando conectar por SSH... intento $i de 30"
  sleep 10
done

# Determinar el usuario SSH basado en la AMI
SSH_USER="ec2-user"  # Por defecto para Amazon Linux 2
if [[ $AMI_ID == *"ubuntu"* ]]; then
  SSH_USER="ubuntu"
elif [[ $AMI_ID == *"debian"* ]]; then
  SSH_USER="admin"
elif [[ $AMI_ID == *"centos"* ]]; then
  SSH_USER="centos"
fi

# Copiar scripts de prueba a las instancias
echo "Copiando scripts de prueba a las instancias..."
scp -i ${KEY_NAME}-1.pem -o StrictHostKeyChecking=no -o ConnectTimeout=60 test_${ACCOUNT_NAME_DEV}.sh ${SSH_USER}@$PUBLIC_IP_DEV:~/
scp -i ${KEY_NAME}-2.pem -o StrictHostKeyChecking=no -o ConnectTimeout=60 test_${ACCOUNT_NAME_STAGE}.sh ${SSH_USER}@$PUBLIC_IP_STAGE:~/
scp -i ${KEY_NAME}-3.pem -o StrictHostKeyChecking=no -o ConnectTimeout=60 test_${ACCOUNT_NAME_PROD}.sh ${SSH_USER}@$PUBLIC_IP_PROD:~/

# Ejecutar pruebas de conectividad y guardar resultados
echo "Ejecutando pruebas de conectividad..."
echo "Prueba desde ${ACCOUNT_NAME_DEV^^}..."
ssh -i ${KEY_NAME}-1.pem -o StrictHostKeyChecking=no -o ConnectTimeout=60 ${SSH_USER}@$PUBLIC_IP_DEV "chmod +x test_${ACCOUNT_NAME_DEV}.sh && ./test_${ACCOUNT_NAME_DEV}.sh" > $RESULTS_DIR/${ACCOUNT_NAME_DEV}_results.txt

echo "Prueba desde ${ACCOUNT_NAME_STAGE^^}..."
ssh -i ${KEY_NAME}-2.pem -o StrictHostKeyChecking=no -o ConnectTimeout=60 ${SSH_USER}@$PUBLIC_IP_STAGE "chmod +x test_${ACCOUNT_NAME_STAGE}.sh && ./test_${ACCOUNT_NAME_STAGE}.sh" > $RESULTS_DIR/${ACCOUNT_NAME_STAGE}_results.txt

echo "Prueba desde ${ACCOUNT_NAME_PROD^^}..."
ssh -i ${KEY_NAME}-3.pem -o StrictHostKeyChecking=no -o ConnectTimeout=60 ${SSH_USER}@$PUBLIC_IP_PROD "chmod +x test_${ACCOUNT_NAME_PROD}.sh && ./test_${ACCOUNT_NAME_PROD}.sh" > $RESULTS_DIR/${ACCOUNT_NAME_PROD}_results.txt

# Generar HTML con los resultados
echo "Generando reporte HTML con los resultados..."
cat > $RESULTS_DIR/directory_service_connectivity_report.html << EOF
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte de Pruebas de Conectividad a Directory Services</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            color: #333;
        }
        h1 {
            color: #0066cc;
            border-bottom: 2px solid #0066cc;
            padding-bottom: 10px;
        }
        h2 {
            color: #0099cc;
            margin-top: 30px;
        }
        h3 {
            color: #00a3cc;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .section {
            margin-bottom: 30px;
            padding: 20px;
            background-color: #f9f9f9;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        pre {
            background-color: #f0f0f0;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            font-family: Consolas, Monaco, 'Andale Mono', monospace;
            white-space: pre-wrap;
        }
        .success {
            color: #2e8b57;
            font-weight: bold;
        }
        .warning {
            color: #ff8c00;
            font-weight: bold;
        }
        .error {
            color: #dc3545;
            font-weight: bold;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px 12px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Reporte de Pruebas de Conectividad a Directory Services</h1>
        
        <div class="section">
            <h2>Resumen de Pruebas</h2>
            <p>Este reporte muestra los resultados de las pruebas de conectividad desde cada entorno (${ACCOUNT_NAME_DEV^^}, ${ACCOUNT_NAME_STAGE^^}, ${ACCOUNT_NAME_PROD^^}) hacia su respectivo AWS Directory Service.</p>
            <p>Fecha de ejecución: $(date)</p>
            
            <table>
                <tr>
                    <th>Entorno</th>
                    <th>IP de Instancia</th>
                    <th>IP de Directory Service</th>
                </tr>
                <tr>
                    <td>${ACCOUNT_NAME_DEV^^}</td>
                    <td>$IP_DEV</td>
                    <td>$IP_DIR_DEV</td>
                </tr>
                <tr>
                    <td>${ACCOUNT_NAME_STAGE^^}</td>
                    <td>$IP_STAGE</td>
                    <td>$IP_DIR_STAGE</td>
                </tr>
                <tr>
                    <td>${ACCOUNT_NAME_PROD^^}</td>
                    <td>$IP_PROD</td>
                    <td>$IP_DIR_PROD</td>
                </tr>
            </table>
        </div>
        
        <div class="section">
            <h2>Pruebas desde ${ACCOUNT_NAME_DEV^^}</h2>
            <p>Origen: $IP_DEV</p>
            <p>Destino: $IP_DIR_DEV (Directory Service ${ACCOUNT_NAME_DEV^^})</p>
            <pre>$(cat $RESULTS_DIR/${ACCOUNT_NAME_DEV}_results.txt)</pre>
            <p>Estado: 
            $(if grep -q "0% packet loss" $RESULTS_DIR/${ACCOUNT_NAME_DEV}_results.txt; then 
                echo "<span class=\"success\">ÉXITO</span>"; 
              else 
                echo "<span class=\"error\">FALLO</span>"; 
              fi)
            </p>
        </div>
        
        <div class="section">
            <h2>Pruebas desde ${ACCOUNT_NAME_STAGE^^}</h2>
            <p>Origen: $IP_STAGE</p>
            <p>Destino: $IP_DIR_STAGE (Directory Service ${ACCOUNT_NAME_STAGE^^})</p>
            <pre>$(cat $RESULTS_DIR/${ACCOUNT_NAME_STAGE}_results.txt)</pre>
            <p>Estado: 
            $(if grep -q "0% packet loss" $RESULTS_DIR/${ACCOUNT_NAME_STAGE}_results.txt; then 
                echo "<span class=\"success\">ÉXITO</span>"; 
              else 
                echo "<span class=\"error\">FALLO</span>"; 
              fi)
            </p>
        </div>
        
        <div class="section">
            <h2>Pruebas desde ${ACCOUNT_NAME_PROD^^}</h2>
            <p>Origen: $IP_PROD</p>
            <p>Destino: $IP_DIR_PROD (Directory Service ${ACCOUNT_NAME_PROD^^})</p>
            <pre>$(cat $RESULTS_DIR/${ACCOUNT_NAME_PROD}_results.txt)</pre>
            <p>Estado: 
            $(if grep -q "0% packet loss" $RESULTS_DIR/${ACCOUNT_NAME_PROD}_results.txt; then 
                echo "<span class=\"success\">ÉXITO</span>"; 
              else 
                echo "<span class=\"error\">FALLO</span>"; 
              fi)
            </p>
        </div>
        
        <div class="section">
            <h2>Conclusión</h2>
            <p>Resumen de los resultados de las pruebas:</p>
            <table>
                <tr>
                    <th>Entorno</th>
                    <th>Estado</th>
                </tr>
                <tr>
                    <td>${ACCOUNT_NAME_DEV^^}</td>
                    <td>
                    $(if grep -q "0% packet loss" $RESULTS_DIR/${ACCOUNT_NAME_DEV}_results.txt; then 
                        echo "<span class=\"success\">ÉXITO</span>"; 
                      else 
                        echo "<span class=\"error\">FALLO</span>"; 
                      fi)
                    </td>
                </tr>
                <tr>
                    <td>${ACCOUNT_NAME_STAGE^^}</td>
                    <td>
                    $(if grep -q "0% packet loss" $RESULTS_DIR/${ACCOUNT_NAME_STAGE}_results.txt; then 
                        echo "<span class=\"success\">ÉXITO</span>"; 
                      else 
                        echo "<span class=\"error\">FALLO</span>"; 
                      fi)
                    </td>
                </tr>
                <tr>
                    <td>${ACCOUNT_NAME_PROD^^}</td>
                    <td>
                    $(if grep -q "0% packet loss" $RESULTS_DIR/${ACCOUNT_NAME_PROD}_results.txt; then 
                        echo "<span class=\"success\">ÉXITO</span>"; 
                      else 
                        echo "<span class=\"error\">FALLO</span>"; 
                      fi)
                    </td>
                </tr>
            </table>
        </div>
    </div>
</body>
</html>
EOF

echo "Reporte HTML generado en $RESULTS_DIR/directory_service_connectivity_report.html"
# Limpiar recursos
echo "Limpiando recursos..."

# Liberar IPs elásticas si se crearon
if [ ! -z "$ELASTIC_IP_DEV" ]; then
  ASSOCIATION_ID=$(aws ec2 describe-addresses --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --allocation-ids $ELASTIC_IP_DEV --query "Addresses[0].AssociationId" --output text)
  aws ec2 disassociate-address --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --association-id $ASSOCIATION_ID
  aws ec2 release-address --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --allocation-id $ELASTIC_IP_DEV
fi

if [ ! -z "$ELASTIC_IP_STAGE" ]; then
  ASSOCIATION_ID=$(aws ec2 describe-addresses --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --allocation-ids $ELASTIC_IP_STAGE --query "Addresses[0].AssociationId" --output text)
  aws ec2 disassociate-address --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --association-id $ASSOCIATION_ID
  aws ec2 release-address --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --allocation-id $ELASTIC_IP_STAGE
fi

if [ ! -z "$ELASTIC_IP_PROD" ]; then
  ASSOCIATION_ID=$(aws ec2 describe-addresses --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --allocation-ids $ELASTIC_IP_PROD --query "Addresses[0].AssociationId" --output text)
  aws ec2 disassociate-address --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --association-id $ASSOCIATION_ID
  aws ec2 release-address --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --allocation-id $ELASTIC_IP_PROD
fi

# Terminar instancias
aws ec2 terminate-instances --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --instance-ids $INSTANCE_DEV
aws ec2 terminate-instances --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --instance-ids $INSTANCE_STAGE
aws ec2 terminate-instances --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --instance-ids $INSTANCE_PROD

echo "Esperando a que las instancias se terminen..."
aws ec2 wait instance-terminated --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --instance-ids $INSTANCE_DEV
aws ec2 wait instance-terminated --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --instance-ids $INSTANCE_STAGE
aws ec2 wait instance-terminated --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --instance-ids $INSTANCE_PROD

# Eliminar grupos de seguridad y key pairs
aws ec2 delete-security-group --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --group-id $SG_DEV
aws ec2 delete-security-group --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --group-id $SG_STAGE
aws ec2 delete-security-group --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --group-id $SG_PROD

aws ec2 delete-key-pair --profile $ACCOUNT_NAME_DEV --region $AWS_REGION --key-name $KEY_NAME
aws ec2 delete-key-pair --profile $ACCOUNT_NAME_STAGE --region $AWS_REGION --key-name $KEY_NAME
aws ec2 delete-key-pair --profile $ACCOUNT_NAME_PROD --region $AWS_REGION --key-name $KEY_NAME

rm -f ${KEY_NAME}-*.pem
rm -f test_*.sh

echo "Pruebas de conectividad completadas. Los resultados están disponibles en el directorio $RESULTS_DIR"
