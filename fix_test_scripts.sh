#!/bin/bash

# Script para corregir los scripts de prueba

# Corregir el script run_all_tests.sh
if [ -f ./run_all_tests.sh ]; then
    sed -i 's/source .env/source .env || true/g' ./run_all_tests.sh
    echo "Script run_all_tests.sh corregido."
fi

# Corregir los scripts de prueba en el directorio test_connections
for script in ./test_connections/*.sh; do
    if [ -f "$script" ]; then
        sed -i 's/source ..\/\.env/source ..\/\.env || true/g' "$script"
        echo "Script $script corregido."
    fi
done

echo "Todos los scripts de prueba han sido corregidos."
