# Migración de Active Directory - Terraform

Este proyecto contiene la infraestructura como código (IaC) para la migración de Active Directory en AWS utilizando Terraform. Permite desplegar y gestionar una infraestructura completa de Active Directory distribuida en múltiples cuentas AWS con conectividad entre ellas.

## Estructura del Proyecto

- `modules/`: Contiene los módulos de Terraform para cada cuenta
  - `dev/`: Módulo para la cuenta de desarrollo
  - `prod/`: Módulo para la cuenta de producción
  - `stage/`: Módulo para la cuenta de staging
  - `operaciones/`: Módulo para la cuenta de operaciones (gestiona recursos compartidos)
    - `directory_service.tf`: Configuración de los servicios de Microsoft AD
    - `directory_security.tf`: Configuración de grupos de seguridad para AD
    - `directory_eni_rules.tf`: Reglas específicas para los ENIs de AD
    - `main.tf`: Configuración de red y Transit Gateway
- `variables.tf`: Definición de variables globales
- `terraform.tfvars`: Valores de las variables (cargados desde `.env`)
- `provider.tf`: Configuración de proveedores AWS para múltiples cuentas
- `main.tf`: Configuración principal de Terraform y llamadas a módulos
- `outputs.tf`: Definición de salidas del proyecto
- `setup_aws_profiles.sh`: Script para configurar perfiles de AWS CLI
- `run_terraform_plan_profiles.sh`: Script para ejecutar terraform plan
- `run_terraform_apply_profiles.sh`: Script para ejecutar terraform apply
- `run_terraform_destroy.sh`: Script para ejecutar terraform destroy
- `check_aws_credential.sh`: Script para verificar credenciales de AWS

## Requisitos

- Terraform >= 1.2.0
- AWS CLI instalado y configurado
- Archivo `.env` con las credenciales y configuraciones necesarias
- Permisos adecuados en las cuentas AWS para crear y gestionar recursos
- Acceso a múltiples cuentas AWS (operaciones, dev, stage, prod)

## Configuración

1. Copia el archivo `.env.example` a `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edita el archivo `.env` con tus credenciales de AWS y otros valores necesarios:
   ```bash
   nano .env
   ```

3. Configura los perfiles de AWS CLI ejecutando:
   ```bash
   source ./setup_aws_profiles.sh
   ```
   Este script verifica si los perfiles ya existen en `~/.aws/credentials` y solo los crea o actualiza si es necesario.

4. Verifica que las credenciales de AWS sean correctas:
   ```bash
   ./check_aws_credential.sh
   ```

## Uso

### Verificación de Credenciales

Para verificar que las credenciales de AWS estén configuradas correctamente:

```bash
./check_aws_credential.sh
```

### Planificación

Para generar un plan de Terraform y revisar los cambios antes de aplicarlos:

```bash
./run_terraform_plan_profiles.sh
```

### Aplicación

Para aplicar los cambios y desplegar la infraestructura:

```bash
./run_terraform_apply_profiles.sh
```

### Destrucción

Para eliminar toda la infraestructura creada:

```bash
./run_terraform_destroy.sh
```

## Notas Importantes

- Todos los valores de configuración se toman desde el archivo `.env`
- Los scripts configuran automáticamente los perfiles de AWS CLI para cada cuenta
- Se verifica la conectividad con AWS antes de ejecutar los comandos de Terraform
- Las credenciales de AWS se pasan directamente a Terraform para cada proveedor
- La destrucción de recursos puede tomar tiempo, especialmente para servicios como Active Directory (hasta 8-10 minutos)
- Se implementan tiempos de espera adecuados para asegurar la correcta creación de recursos dependientes
- Los servicios de Active Directory requieren configuración específica de seguridad que se maneja automáticamente

## Recursos Creados

### Networking
- VPCs en cada cuenta con nombres dinámicos y CIDRs configurables
- Subnets públicas y privadas distribuidas en múltiples zonas de disponibilidad (por defecto us-east-1a y us-east-1b)
- Internet Gateways para acceso a internet
- NAT Gateways para permitir que las subnets privadas accedan a internet
- Transit Gateway para conectividad entre cuentas
- Tablas de ruteo con rutas configuradas para comunicación entre VPCs
- Elastic IPs para los NAT Gateways

### Seguridad
- Security Groups con reglas específicas para Active Directory
- Reglas de tráfico configuradas para permitir la comunicación necesaria entre servicios
- Compartición de recursos entre cuentas mediante AWS RAM (Resource Access Manager)
- Reglas específicas para los protocolos requeridos por Active Directory:
  - DNS (TCP/UDP 53)
  - Kerberos (TCP/UDP 88)
  - LDAP (TCP/UDP 389)
  - LDAPS (TCP 636)
  - SMB/CIFS (TCP 445)
  - Global Catalog (TCP 3268-3269)
  - RPC (TCP 135)
  - Puertos efímeros para RPC (TCP/UDP 1024-65535)
  - NTP (UDP 123)
  - ICMP (ping)

### Active Directory
- Servicios de Microsoft AD administrados por AWS en cada cuenta
- Configuración de DNS y DHCP para soportar Active Directory
- Reglas de seguridad específicas para protocolos de AD
- Integración entre dominios de Active Directory
- Configuración de ENIs (Elastic Network Interfaces) para AD
- Tiempos de espera adecuados para la creación y configuración de AD

### Automatización
- Scripts para facilitar la gestión del ciclo de vida de la infraestructura
- Validación de credenciales y conectividad antes de operaciones
- Manejo adecuado de dependencias entre recursos
- Configuración automática de perfiles AWS CLI
- Verificación de conectividad antes de ejecutar operaciones

## Mejoras Recientes

- Refactorización del script `setup_aws_profiles.sh` para verificar la existencia de perfiles antes de crearlos
- Implementación de detección inteligente de perfiles AWS existentes para evitar duplicados
- Optimización del proceso de destrucción de recursos para evitar dependencias bloqueantes
- Mejora en la gestión de perfiles AWS para múltiples cuentas
- Implementación de tiempos de espera adecuados para recursos que requieren tiempo de aprovisionamiento
- Configuración mejorada de reglas de seguridad para Active Directory usando `for_each` con definiciones locales
- Documentación ampliada con detalles de implementación
- Corrección de problemas de conectividad entre VPCs
- Mejora en la estructura de módulos para facilitar la reutilización
- Refactorización de las reglas de seguridad para los ENIs de Active Directory
- Optimización de la secuencia de creación y destrucción de recursos
- Implementación de verificaciones de conectividad más robustas
- Mejora en el manejo de errores en los scripts de automatización

## Arquitectura

La arquitectura implementada consiste en:

1. **Cuenta de Operaciones**: Gestiona recursos compartidos como Transit Gateway y servicios de Active Directory
2. **Cuentas de Aplicación** (Dev, Stage, Prod): Contienen las VPCs y recursos específicos de cada ambiente
3. **Conectividad**: Transit Gateway permite la comunicación entre todas las VPCs
4. **Seguridad**: Reglas específicas para permitir solo el tráfico necesario entre recursos

Esta arquitectura permite una separación clara de responsabilidades mientras mantiene la conectividad necesaria para la integración de Active Directory entre ambientes.
