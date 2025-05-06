#!/bin/bash

# Script para corregir el formato de las zonas de disponibilidad en el archivo .env

# Crear una copia de seguridad del archivo .env
cp .env .env.bak

# Reemplazar el formato de las zonas de disponibilidad
sed -i 's/AVAILABILITY_ZONES=.*$/AVAILABILITY_ZONES='"'"'us-east-1a,us-east-1b'"'"'/g' .env

echo "Archivo .env corregido correctamente."
