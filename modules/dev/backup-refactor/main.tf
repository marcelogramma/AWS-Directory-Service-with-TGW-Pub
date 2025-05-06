# Configuración de la VPC para la cuenta Dev
resource "aws_vpc" "vpc_dev" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "vpc-dev"
  }
}

# Subnets para la cuenta Dev
resource "aws_subnet" "subnet_dev" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc_dev.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "subnet-dev-${count.index}"
  }
}

# Route Table para la cuenta Dev
resource "aws_route_table" "rt_dev" {
  vpc_id = aws_vpc.vpc_dev.id
  
  tags = {
    Name = "rt-dev"
  }
}

# Asociación de Route Table con Subnets
resource "aws_route_table_association" "rta_dev" {
  count          = length(aws_subnet.subnet_dev)
  subnet_id      = aws_subnet.subnet_dev[count.index].id
  route_table_id = aws_route_table.rt_dev.id
}

# Attachment al Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_dev" {
  subnet_ids             = [for subnet in aws_subnet.subnet_dev : subnet.id]
  transit_gateway_id     = var.transit_gateway_id
  vpc_id                 = aws_vpc.vpc_dev.id
  appliance_mode_support = "enable"
  
  tags = {
    Name = "tgw-attachment-dev"
  }
}

# Rutas hacia las VPCs de Operaciones a través del Transit Gateway
resource "aws_route" "route_to_operaciones_dev" {
  route_table_id         = aws_route_table.rt_dev.id
  destination_cidr_block = var.operaciones_vpc_cidr_dev
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "route_to_operaciones_stage" {
  route_table_id         = aws_route_table.rt_dev.id
  destination_cidr_block = var.operaciones_vpc_cidr_stage
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "route_to_operaciones_prod" {
  route_table_id         = aws_route_table.rt_dev.id
  destination_cidr_block = var.operaciones_vpc_cidr_prod
  transit_gateway_id     = var.transit_gateway_id
}
