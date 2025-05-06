#!/bin/bash

# Script para ejecutar todas las pruebas con correcciones

echo "===== Configurando AWS CLI con región us-east-1 ====="
export AWS_DEFAULT_REGION=us-east-1

echo ""
echo "===== Ejecutando pruebas de Directory Service ====="
./test_connections/test_directory_service.sh

echo ""
echo "===== Ejecutando pruebas de Transit Gateway ====="
./test_connections/test_transit_gateway.sh

echo ""
echo "===== Generando scripts para pruebas de conectividad en CloudShell ====="
./test_connections/test_conectividad_cloudshell.sh

echo ""
echo "===== Ejecutando pruebas de Terraform con Terratest ====="
cd tests
go mod tidy
go test -v

echo ""
echo "===== Todas las pruebas han sido ejecutadas ====="
echo "Para realizar pruebas de conectividad completas entre VPCs, utiliza los scripts generados para CloudShell."
echo "También puedes ejecutar el script test_connections/test_conectividad.sh para realizar pruebas de conectividad con instancias EC2."
