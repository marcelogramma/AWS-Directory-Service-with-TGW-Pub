variable "region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR para la VPC de Stage"
  type        = string
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para desplegar la infraestructura"
  type        = list(string)
}

variable "transit_gateway_id" {
  description = "ID del Transit Gateway compartido desde la cuenta de Operaciones"
  type        = string
}

variable "operaciones_vpc_cidr_dev" {
  description = "CIDR de la VPC de Operaciones Dev"
  type        = string
}

variable "operaciones_vpc_cidr_stage" {
  description = "CIDR de la VPC de Operaciones Stage"
  type        = string
}

variable "operaciones_vpc_cidr_prod" {
  description = "CIDR de la VPC de Operaciones Prod"
  type        = string
}

variable "vpc_name" {
  description = "Nombre de la VPC"
  type        = string
}

variable "subnet_name" {
  description = "Nombre base para las subredes"
  type        = string
}

# Variables para nombres de Internet Gateways
variable "igw_name_stage" {
  description = "Nombre del Internet Gateway para la VPC de staging"
  type        = string
  default     = "igw-stage"
}

# Variables para nombres de NAT Gateways
variable "natgw_name_stage" {
  description = "Nombre del NAT Gateway para la VPC de staging"
  type        = string
  default     = "nat-stage"
}

# Variables para nombres de Elastic IPs
variable "eip_name_stage" {
  description = "Nombre de la Elastic IP para el NAT Gateway de staging"
  type        = string
  default     = "eip-nat-stage"
}

# Variables para nombres de tablas de ruteo
variable "rt_name_stage_public" {
  description = "Nombre de la tabla de ruteo pública para la VPC de staging"
  type        = string
  default     = "rt-stage-public"
}

variable "rt_name_stage_private" {
  description = "Nombre de la tabla de ruteo privada para la VPC de staging"
  type        = string
  default     = "rt-stage-private"
}

# Variables para nombres de Transit Gateway Attachments
variable "tgw_attachment_name_stage" {
  description = "Nombre del Transit Gateway Attachment para la cuenta de staging"
  type        = string
  default     = "tgw-attachment-stage"
}
