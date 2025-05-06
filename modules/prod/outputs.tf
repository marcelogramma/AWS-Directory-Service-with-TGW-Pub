output "vpc_id" {
  description = "ID de la VPC de Prod"
  value       = aws_vpc.vpc_prod.id
}

output "subnet_ids" {
  description = "IDs de las subnets de Prod"
  value       = concat(aws_subnet.subnet_prod_public[*].id, aws_subnet.subnet_prod_private[*].id)
}

output "tgw_attachment_id" {
  description = "ID del Transit Gateway Attachment para la VPC de Prod"
  value       = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_prod.id
}
