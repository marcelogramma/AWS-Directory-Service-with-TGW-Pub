#!/bin/bash

# Script para verificar las credenciales de AWS

# Cargar variables de entorno
source ./setup_aws_profiles.sh

# Verificar que los perfiles se hayan configurado correctamente
if [ $? -ne 0 ]; then
  echo "Error: No se pudieron configurar los perfiles de AWS CLI"
  exit 1
fi

# Función para verificar un perfil
check_profile() {
  local profile=$1
  echo "Verificando perfil: $profile"
  echo "-------------------------"
  aws sts get-caller-identity --profile $profile
  if [ $? -eq 0 ]; then
    echo "✅ Perfil $profile configurado correctamente"
  else
    echo "❌ Error en el perfil $profile"
  fi
  echo ""
}

# Verificar cada perfil
check_profile $ACCOUNT_NAME_OPERACIONES
check_profile $ACCOUNT_NAME_DEV
check_profile $ACCOUNT_NAME_STAGE
check_profile $ACCOUNT_NAME_PROD

echo "Verificación de credenciales completada"
