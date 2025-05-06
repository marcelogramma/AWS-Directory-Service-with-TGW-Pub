# Módulos para cada cuenta
module "operaciones" {
  source = "./modules/operaciones"
  
  providers = {
    aws = aws.operaciones
  }
  
  region                = var.region
  vpc_cidr_dev          = var.vpc_cidr_operaciones_dev
  vpc_cidr_stage        = var.vpc_cidr_operaciones_stage
  vpc_cidr_prod         = var.vpc_cidr_operaciones_prod
  availability_zones    = var.availability_zones
  directory_name_dev    = var.directory_name_dev
  directory_name_stage  = var.directory_name_stage
  directory_name_prod   = var.directory_name_prod
  directory_password    = var.directory_password
  vpc_cidr_dev_account  = var.vpc_cidr_dev
  vpc_cidr_stage_account = var.vpc_cidr_stage
  vpc_cidr_prod_account = var.vpc_cidr_prod
  dev_account_id        = var.dev_account_id
  stage_account_id      = var.stage_account_id
  prod_account_id       = var.prod_account_id
  vpc_name_dev          = "${var.vpc_name_operaciones}-${var.account_name_dev}"
  vpc_name_stage        = "${var.vpc_name_operaciones}-${var.account_name_stage}"
  vpc_name_prod         = "${var.vpc_name_operaciones}-${var.account_name_prod}"
  subnet_name_dev       = "${var.subnet_name_operaciones}-${var.account_name_dev}"
  subnet_name_stage     = "${var.subnet_name_operaciones}-${var.account_name_stage}"
  subnet_name_prod      = "${var.subnet_name_operaciones}-${var.account_name_prod}"
  
  # Nombres para Transit Gateway
  tgw_name              = var.tgw_name
  tgw_description       = var.tgw_description
  ram_share_name        = var.ram_share_name
  
  # Nombres para Internet Gateways
  igw_name_operaciones_dev    = var.igw_name_operaciones_dev
  igw_name_operaciones_stage  = var.igw_name_operaciones_stage
  igw_name_operaciones_prod   = var.igw_name_operaciones_prod
  
  # Nombres para NAT Gateways
  natgw_name_operaciones_dev   = var.natgw_name_operaciones_dev
  natgw_name_operaciones_stage = var.natgw_name_operaciones_stage
  natgw_name_operaciones_prod  = var.natgw_name_operaciones_prod
  
  # Nombres para Elastic IPs
  eip_name_operaciones_dev     = var.eip_name_operaciones_dev
  eip_name_operaciones_stage   = var.eip_name_operaciones_stage
  eip_name_operaciones_prod    = var.eip_name_operaciones_prod
  
  # Nombres para Security Groups
  sg_directory_name_dev        = var.sg_directory_name_dev
  sg_directory_name_stage      = var.sg_directory_name_stage
  sg_directory_name_prod       = var.sg_directory_name_prod
  
  # Nombres para Transit Gateway Attachments
  tgw_attachment_name_operaciones_dev   = var.tgw_attachment_name_operaciones_dev
  tgw_attachment_name_operaciones_stage = var.tgw_attachment_name_operaciones_stage
  tgw_attachment_name_operaciones_prod  = var.tgw_attachment_name_operaciones_prod
  
  # Nombres para tablas de ruteo
  rt_name_operaciones_dev_public    = var.rt_name_operaciones_dev_public
  rt_name_operaciones_dev_private   = var.rt_name_operaciones_dev_private
  rt_name_operaciones_stage_public  = var.rt_name_operaciones_stage_public
  rt_name_operaciones_stage_private = var.rt_name_operaciones_stage_private
  rt_name_operaciones_prod_public   = var.rt_name_operaciones_prod_public
  rt_name_operaciones_prod_private  = var.rt_name_operaciones_prod_private
}

module "dev" {
  source = "./modules/dev"
  
  providers = {
    aws = aws.dev
  }
  
  region                = var.region
  vpc_cidr              = var.vpc_cidr_dev
  availability_zones    = var.availability_zones
  transit_gateway_id    = module.operaciones.transit_gateway_id
  operaciones_vpc_cidr_dev = var.vpc_cidr_operaciones_dev
  operaciones_vpc_cidr_stage = var.vpc_cidr_operaciones_stage
  operaciones_vpc_cidr_prod = var.vpc_cidr_operaciones_prod
  vpc_name              = var.vpc_name_dev
  subnet_name           = var.subnet_name_dev
  
  # Nombres para Internet Gateways, NAT Gateways, Elastic IPs
  igw_name_dev          = var.igw_name_dev
  natgw_name_dev        = var.natgw_name_dev
  eip_name_dev          = var.eip_name_dev
  
  # Nombres para tablas de ruteo
  rt_name_dev_public    = var.rt_name_dev_public
  rt_name_dev_private   = var.rt_name_dev_private
  
  # Nombres para Transit Gateway Attachments
  tgw_attachment_name_dev = var.tgw_attachment_name_dev
}

module "stage" {
  source = "./modules/stage"
  
  providers = {
    aws = aws.stage
  }
  
  region                = var.region
  vpc_cidr              = var.vpc_cidr_stage
  availability_zones    = var.availability_zones
  transit_gateway_id    = module.operaciones.transit_gateway_id
  operaciones_vpc_cidr_dev = var.vpc_cidr_operaciones_dev
  operaciones_vpc_cidr_stage = var.vpc_cidr_operaciones_stage
  operaciones_vpc_cidr_prod = var.vpc_cidr_operaciones_prod
  vpc_name              = var.vpc_name_stage
  subnet_name           = var.subnet_name_stage
  
  # Nombres para Internet Gateways, NAT Gateways, Elastic IPs
  igw_name_stage        = var.igw_name_stage
  natgw_name_stage      = var.natgw_name_stage
  eip_name_stage        = var.eip_name_stage
  
  # Nombres para tablas de ruteo
  rt_name_stage_public  = var.rt_name_stage_public
  rt_name_stage_private = var.rt_name_stage_private
  
  # Nombres para Transit Gateway Attachments
  tgw_attachment_name_stage = var.tgw_attachment_name_stage
}

module "prod" {
  source = "./modules/prod"
  
  providers = {
    aws = aws.prod
  }
  
  region                = var.region
  vpc_cidr              = var.vpc_cidr_prod
  availability_zones    = var.availability_zones
  transit_gateway_id    = module.operaciones.transit_gateway_id
  operaciones_vpc_cidr_dev = var.vpc_cidr_operaciones_dev
  operaciones_vpc_cidr_stage = var.vpc_cidr_operaciones_stage
  operaciones_vpc_cidr_prod = var.vpc_cidr_operaciones_prod
  vpc_name              = var.vpc_name_prod
  subnet_name           = var.subnet_name_prod
  
  # Nombres para Internet Gateways, NAT Gateways, Elastic IPs
  igw_name_prod         = var.igw_name_prod
  natgw_name_prod       = var.natgw_name_prod
  eip_name_prod         = var.eip_name_prod
  
  # Nombres para tablas de ruteo
  rt_name_prod_public   = var.rt_name_prod_public
  rt_name_prod_private  = var.rt_name_prod_private
  
  # Nombres para Transit Gateway Attachments
  tgw_attachment_name_prod = var.tgw_attachment_name_prod
}

# Outputs
output "transit_gateway_id" {
  description = "ID del Transit Gateway"
  value       = module.operaciones.transit_gateway_id
}

output "directory_service_ids" {
  description = "IDs de los servicios de directorio"
  value = {
    dev   = module.operaciones.directory_service_dev_id
    stage = module.operaciones.directory_service_stage_id
    prod  = module.operaciones.directory_service_prod_id
  }
}

output "vpc_ids" {
  description = "IDs de las VPCs"
  value = {
    operaciones_dev   = module.operaciones.vpc_dev_id
    operaciones_stage = module.operaciones.vpc_stage_id
    operaciones_prod  = module.operaciones.vpc_prod_id
    dev               = module.dev.vpc_id
    stage             = module.stage.vpc_id
    prod              = module.prod.vpc_id
  }
}

output "directory_security_groups" {
  description = "IDs de los grupos de seguridad de los servicios de directorio"
  value = {
    dev   = module.operaciones.directory_service_dev_sg_id
    stage = module.operaciones.directory_service_stage_sg_id
    prod  = module.operaciones.directory_service_prod_sg_id
  }
}
