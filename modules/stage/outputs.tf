output "vpc_id" {
  description = "ID de la VPC de Stage"
  value       = aws_vpc.vpc_stage.id
}

output "subnet_ids" {
  description = "IDs de las subnets de Stage"
  value       = concat(aws_subnet.subnet_stage_public[*].id, aws_subnet.subnet_stage_private[*].id)
}

output "tgw_attachment_id" {
  description = "ID del Transit Gateway Attachment para la VPC de Stage"
  value       = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_stage.id
}
