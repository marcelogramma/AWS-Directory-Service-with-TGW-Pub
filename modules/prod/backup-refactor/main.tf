# Configuración de la VPC para la cuenta Prod
resource "aws_vpc" "vpc_prod" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "vpc-prod"
  }
}

# Subnets para la cuenta Prod
resource "aws_subnet" "subnet_prod" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc_prod.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "subnet-prod-${count.index}"
  }
}

# Internet Gateway para la cuenta Prod
resource "aws_internet_gateway" "igw_prod" {
  vpc_id = aws_vpc.vpc_prod.id
  
  tags = {
    Name = "igw-prod"
  }
}

# Route Table para la cuenta Prod
resource "aws_route_table" "rt_prod" {
  vpc_id = aws_vpc.vpc_prod.id
  
  tags = {
    Name = "rt-prod"
  }
}

# Asociación de Route Table con Subnets
resource "aws_route_table_association" "rta_prod" {
  count          = length(aws_subnet.subnet_prod)
  subnet_id      = aws_subnet.subnet_prod[count.index].id
  route_table_id = aws_route_table.rt_prod.id
}

# Ruta por defecto hacia Internet Gateway
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.rt_prod.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_prod.id
}

# Attachment al Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_prod" {
  subnet_ids             = [for subnet in aws_subnet.subnet_prod : subnet.id]
  transit_gateway_id     = var.transit_gateway_id
  vpc_id                 = aws_vpc.vpc_prod.id
  appliance_mode_support = "enable"
  
  tags = {
    Name = "tgw-attachment-prod"
  }
}

# Esperar a que el attachment esté disponible
resource "time_sleep" "wait_for_tgw_attachment" {
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_prod]
  
  create_duration = "30s"
}

# Rutas hacia las VPCs de Operaciones a través del Transit Gateway
resource "aws_route" "route_to_operaciones_dev" {
  depends_on             = [time_sleep.wait_for_tgw_attachment]
  route_table_id         = aws_route_table.rt_prod.id
  destination_cidr_block = var.operaciones_vpc_cidr_dev
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "route_to_operaciones_stage" {
  depends_on             = [time_sleep.wait_for_tgw_attachment]
  route_table_id         = aws_route_table.rt_prod.id
  destination_cidr_block = var.operaciones_vpc_cidr_stage
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "route_to_operaciones_prod" {
  depends_on             = [time_sleep.wait_for_tgw_attachment]
  route_table_id         = aws_route_table.rt_prod.id
  destination_cidr_block = var.operaciones_vpc_cidr_prod
  transit_gateway_id     = var.transit_gateway_id
}
