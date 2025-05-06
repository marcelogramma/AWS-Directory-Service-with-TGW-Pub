output "vpc_id" {
  description = "ID de la VPC de Dev"
  value       = aws_vpc.vpc_dev.id
}

output "subnet_ids" {
  description = "IDs de las subnets de Dev"
  value       = concat(aws_subnet.subnet_dev_public[*].id, aws_subnet.subnet_dev_private[*].id)
}

output "tgw_attachment_id" {
  description = "ID del Transit Gateway Attachment para la VPC de Dev"
  value       = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_dev.id
}
