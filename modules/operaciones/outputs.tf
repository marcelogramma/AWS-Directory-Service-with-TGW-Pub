output "transit_gateway_id" {
  description = "ID del Transit Gateway"
  value       = aws_ec2_transit_gateway.tgw.id
}

output "directory_service_dev_id" {
  description = "ID del servicio de directorio para Dev"
  value       = aws_directory_service_directory.directory_dev.id
}

output "directory_service_stage_id" {
  description = "ID del servicio de directorio para Stage"
  value       = aws_directory_service_directory.directory_stage.id
}

output "directory_service_prod_id" {
  description = "ID del servicio de directorio para Prod"
  value       = aws_directory_service_directory.directory_prod.id
}

output "vpc_dev_id" {
  description = "ID de la VPC de Operaciones Dev"
  value       = aws_vpc.vpc_operaciones_dev.id
}

output "vpc_stage_id" {
  description = "ID de la VPC de Operaciones Stage"
  value       = aws_vpc.vpc_operaciones_stage.id
}

output "vpc_prod_id" {
  description = "ID de la VPC de Operaciones Prod"
  value       = aws_vpc.vpc_operaciones_prod.id
}

output "directory_service_dev_sg_id" {
  description = "ID del grupo de seguridad del servicio de directorio para Dev"
  value       = aws_directory_service_directory.directory_dev.security_group_id
}

output "directory_service_stage_sg_id" {
  description = "ID del grupo de seguridad del servicio de directorio para Stage"
  value       = aws_directory_service_directory.directory_stage.security_group_id
}

output "directory_service_prod_sg_id" {
  description = "ID del grupo de seguridad del servicio de directorio para Prod"
  value       = aws_directory_service_directory.directory_prod.security_group_id
}

output "custom_sg_dev_id" {
  description = "ID del grupo de seguridad personalizado para Dev"
  value       = aws_security_group.sg_directory_dev.id
}

output "custom_sg_stage_id" {
  description = "ID del grupo de seguridad personalizado para Stage"
  value       = aws_security_group.sg_directory_stage.id
}

output "custom_sg_prod_id" {
  description = "ID del grupo de seguridad personalizado para Prod"
  value       = aws_security_group.sg_directory_prod.id
}

output "subnet_dev_public_ids" {
  description = "IDs de las subnets públicas de Operaciones Dev"
  value       = aws_subnet.subnet_operaciones_dev_public[*].id
}

output "subnet_dev_private_ids" {
  description = "IDs de las subnets privadas de Operaciones Dev"
  value       = aws_subnet.subnet_operaciones_dev_private[*].id
}

output "subnet_stage_public_ids" {
  description = "IDs de las subnets públicas de Operaciones Stage"
  value       = aws_subnet.subnet_operaciones_stage_public[*].id
}

output "subnet_stage_private_ids" {
  description = "IDs de las subnets privadas de Operaciones Stage"
  value       = aws_subnet.subnet_operaciones_stage_private[*].id
}

output "subnet_prod_public_ids" {
  description = "IDs de las subnets públicas de Operaciones Prod"
  value       = aws_subnet.subnet_operaciones_prod_public[*].id
}

output "subnet_prod_private_ids" {
  description = "IDs de las subnets privadas de Operaciones Prod"
  value       = aws_subnet.subnet_operaciones_prod_private[*].id
}
