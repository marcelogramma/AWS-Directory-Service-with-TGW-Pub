variable "region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
}

# Variables para VPCs en cuenta Operaciones
variable "vpc_cidr_operaciones_dev" {
  description = "CIDR para la VPC de Operaciones Dev"
  type        = string
}

variable "vpc_cidr_operaciones_stage" {
  description = "CIDR para la VPC de Operaciones Stage"
  type        = string
}

variable "vpc_cidr_operaciones_prod" {
  description = "CIDR para la VPC de Operaciones Prod"
  type        = string
}

# Variables para VPCs en otras cuentas
variable "vpc_cidr_dev" {
  description = "CIDR para la VPC de la cuenta Dev"
  type        = string
}

variable "vpc_cidr_stage" {
  description = "CIDR para la VPC de la cuenta Stage"
  type        = string
}

variable "vpc_cidr_prod" {
  description = "CIDR para la VPC de la cuenta Prod"
  type        = string
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para desplegar la infraestructura"
  type        = list(string)
}

# Variables para Directory Service
variable "directory_name_dev" {
  description = "Nombre del directorio para AWS Directory Service Dev"
  type        = string
}

variable "directory_name_stage" {
  description = "Nombre del directorio para AWS Directory Service Stage"
  type        = string
}

variable "directory_name_prod" {
  description = "Nombre del directorio para AWS Directory Service Prod"
  type        = string
}

variable "directory_password" {
  description = "Contraseña para el directorio"
  type        = string
  sensitive   = true
}

# Variables para IDs de cuentas AWS
variable "operaciones_account_id" {
  description = "ID de la cuenta de operaciones"
  type        = string
}

variable "dev_account_id" {
  description = "ID de la cuenta de desarrollo"
  type        = string
}

variable "stage_account_id" {
  description = "ID de la cuenta de staging"
  type        = string
}

variable "prod_account_id" {
  description = "ID de la cuenta de producción"
  type        = string
}

# Variables para nombres de recursos
variable "account_name_dev" {
  description = "Nombre de la cuenta de desarrollo"
  type        = string
}

variable "account_name_stage" {
  description = "Nombre de la cuenta de staging"
  type        = string
}

variable "account_name_prod" {
  description = "Nombre de la cuenta de producción"
  type        = string
}

variable "account_name_operaciones" {
  description = "Nombre de la cuenta de operaciones"
  type        = string
  default     = "operaciones"
}

# Variables para nombres de VPCs
variable "vpc_name_dev" {
  description = "Nombre de la VPC de desarrollo"
  type        = string
}

variable "vpc_name_stage" {
  description = "Nombre de la VPC de staging"
  type        = string
}

variable "vpc_name_prod" {
  description = "Nombre de la VPC de producción"
  type        = string
}

variable "vpc_name_operaciones" {
  description = "Nombre de la VPC de operaciones"
  type        = string
}

# Variables para nombres de subredes
variable "subnet_name_dev" {
  description = "Nombre base para subredes de desarrollo"
  type        = string
}

variable "subnet_name_stage" {
  description = "Nombre base para subredes de staging"
  type        = string
}

variable "subnet_name_prod" {
  description = "Nombre base para subredes de producción"
  type        = string
}

variable "subnet_name_operaciones" {
  description = "Nombre base para subredes de operaciones"
  type        = string
}

# Variables para credenciales AWS (solo para referencia, se tomarán del entorno)
variable "aws_access_key_operaciones" {
  description = "AWS Access Key para la cuenta de operaciones"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_key_operaciones" {
  description = "AWS Secret Key para la cuenta de operaciones"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_access_key_dev" {
  description = "AWS Access Key para la cuenta de desarrollo"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_key_dev" {
  description = "AWS Secret Key para la cuenta de desarrollo"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_access_key_stage" {
  description = "AWS Access Key para la cuenta de staging"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_key_stage" {
  description = "AWS Secret Key para la cuenta de staging"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_access_key_prod" {
  description = "AWS Access Key para la cuenta de producción"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_key_prod" {
  description = "AWS Secret Key para la cuenta de producción"
  type        = string
  default     = ""
  sensitive   = true
}
# Variables para nombres de Internet Gateways
variable "igw_name_dev" {
  description = "Nombre del Internet Gateway para la VPC de desarrollo"
  type        = string
}

variable "igw_name_stage" {
  description = "Nombre del Internet Gateway para la VPC de staging"
  type        = string
}

variable "igw_name_prod" {
  description = "Nombre del Internet Gateway para la VPC de producción"
  type        = string
}

variable "igw_name_operaciones_dev" {
  description = "Nombre del Internet Gateway para la VPC de operaciones dev"
  type        = string
}

variable "igw_name_operaciones_stage" {
  description = "Nombre del Internet Gateway para la VPC de operaciones stage"
  type        = string
}

variable "igw_name_operaciones_prod" {
  description = "Nombre del Internet Gateway para la VPC de operaciones prod"
  type        = string
}

# Variables para nombres de NAT Gateways
variable "natgw_name_dev" {
  description = "Nombre del NAT Gateway para la VPC de desarrollo"
  type        = string
}

variable "natgw_name_stage" {
  description = "Nombre del NAT Gateway para la VPC de staging"
  type        = string
}

variable "natgw_name_prod" {
  description = "Nombre del NAT Gateway para la VPC de producción"
  type        = string
}

variable "natgw_name_operaciones_dev" {
  description = "Nombre del NAT Gateway para la VPC de operaciones dev"
  type        = string
}

variable "natgw_name_operaciones_stage" {
  description = "Nombre del NAT Gateway para la VPC de operaciones stage"
  type        = string
}

variable "natgw_name_operaciones_prod" {
  description = "Nombre del NAT Gateway para la VPC de operaciones prod"
  type        = string
}

# Variables para nombres de Elastic IPs
variable "eip_name_dev" {
  description = "Nombre de la Elastic IP para el NAT Gateway de desarrollo"
  type        = string
}

variable "eip_name_stage" {
  description = "Nombre de la Elastic IP para el NAT Gateway de staging"
  type        = string
}

variable "eip_name_prod" {
  description = "Nombre de la Elastic IP para el NAT Gateway de producción"
  type        = string
}

variable "eip_name_operaciones_dev" {
  description = "Nombre de la Elastic IP para el NAT Gateway de operaciones dev"
  type        = string
}

variable "eip_name_operaciones_stage" {
  description = "Nombre de la Elastic IP para el NAT Gateway de operaciones stage"
  type        = string
}

variable "eip_name_operaciones_prod" {
  description = "Nombre de la Elastic IP para el NAT Gateway de operaciones prod"
  type        = string
}

# Variables para nombres de Security Groups
variable "sg_directory_name_dev" {
  description = "Nombre del Security Group para el Directory Service de desarrollo"
  type        = string
}

variable "sg_directory_name_stage" {
  description = "Nombre del Security Group para el Directory Service de staging"
  type        = string
}

variable "sg_directory_name_prod" {
  description = "Nombre del Security Group para el Directory Service de producción"
  type        = string
}

# Variables para nombres de Transit Gateway
variable "tgw_name" {
  description = "Nombre del Transit Gateway"
  type        = string
}

variable "tgw_description" {
  description = "Descripción del Transit Gateway"
  type        = string
  default     = "Transit Gateway para conectividad entre cuentas"
}

# Variables para nombres de Transit Gateway Attachments
variable "tgw_attachment_name_dev" {
  description = "Nombre del Transit Gateway Attachment para la cuenta de desarrollo"
  type        = string
}

variable "tgw_attachment_name_stage" {
  description = "Nombre del Transit Gateway Attachment para la cuenta de staging"
  type        = string
}

variable "tgw_attachment_name_prod" {
  description = "Nombre del Transit Gateway Attachment para la cuenta de producción"
  type        = string
}

variable "tgw_attachment_name_operaciones_dev" {
  description = "Nombre del Transit Gateway Attachment para la VPC de operaciones dev"
  type        = string
}

variable "tgw_attachment_name_operaciones_stage" {
  description = "Nombre del Transit Gateway Attachment para la VPC de operaciones stage"
  type        = string
}

variable "tgw_attachment_name_operaciones_prod" {
  description = "Nombre del Transit Gateway Attachment para la VPC de operaciones prod"
  type        = string
}

# Variables para nombres de tablas de ruteo
variable "rt_name_dev_public" {
  description = "Nombre de la tabla de ruteo pública para la VPC de desarrollo"
  type        = string
}

variable "rt_name_dev_private" {
  description = "Nombre de la tabla de ruteo privada para la VPC de desarrollo"
  type        = string
}

variable "rt_name_stage_public" {
  description = "Nombre de la tabla de ruteo pública para la VPC de staging"
  type        = string
}

variable "rt_name_stage_private" {
  description = "Nombre de la tabla de ruteo privada para la VPC de staging"
  type        = string
}

variable "rt_name_prod_public" {
  description = "Nombre de la tabla de ruteo pública para la VPC de producción"
  type        = string
}

variable "rt_name_prod_private" {
  description = "Nombre de la tabla de ruteo privada para la VPC de producción"
  type        = string
}

variable "rt_name_operaciones_dev_public" {
  description = "Nombre de la tabla de ruteo pública para la VPC de operaciones dev"
  type        = string
}

variable "rt_name_operaciones_dev_private" {
  description = "Nombre de la tabla de ruteo privada para la VPC de operaciones dev"
  type        = string
}

variable "rt_name_operaciones_stage_public" {
  description = "Nombre de la tabla de ruteo pública para la VPC de operaciones stage"
  type        = string
}

variable "rt_name_operaciones_stage_private" {
  description = "Nombre de la tabla de ruteo privada para la VPC de operaciones stage"
  type        = string
}

variable "rt_name_operaciones_prod_public" {
  description = "Nombre de la tabla de ruteo pública para la VPC de operaciones prod"
  type        = string
}

variable "rt_name_operaciones_prod_private" {
  description = "Nombre de la tabla de ruteo privada para la VPC de operaciones prod"
  type        = string
}

# Variables para nombres de RAM Share
variable "ram_share_name" {
  description = "Nombre del recurso compartido de RAM para el Transit Gateway"
  type        = string
}
