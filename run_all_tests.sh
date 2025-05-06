#!/bin/bash

# Script para ejecutar todas las pruebas de conectividad

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

# Verificar que los scripts existen
if [ ! -f test_connections/test_directory_service_refactored.sh ] || 
   [ ! -f test_connections/test_transit_gateway_refactored.sh ] || 
   [ ! -f test_connections/test_conectividad_refactored.sh ] || 
   [ ! -f test_connections/test_conectividad_cloudshell_refactored.sh ]; then
  echo "Error: No se encontraron todos los scripts de prueba refactorizados"
  exit 1
fi

# Ejecutar pruebas
echo "Ejecutando pruebas de Directory Service..."
chmod +x test_connections/test_directory_service_refactored.sh
./test_connections/test_directory_service_refactored.sh

echo "Ejecutando pruebas de Transit Gateway..."
chmod +x test_connections/test_transit_gateway_refactored.sh
./test_connections/test_transit_gateway_refactored.sh

echo "Generando scripts para CloudShell..."
chmod +x test_connections/test_conectividad_cloudshell_refactored.sh
./test_connections/test_conectividad_cloudshell_refactored.sh

echo "¿Deseas ejecutar las pruebas de conectividad completas? (s/n)"
echo "NOTA: Estas pruebas crearán instancias EC2 temporales en cada cuenta."
read respuesta
if [[ "$respuesta" == "s" || "$respuesta" == "S" ]]; then
  echo "Ejecutando pruebas de conectividad..."
  chmod +x test_connections/test_conectividad_refactored.sh
  ./test_connections/test_conectividad_refactored.sh
else
  echo "Pruebas de conectividad omitidas."
fi

echo "Todas las pruebas han sido completadas."
