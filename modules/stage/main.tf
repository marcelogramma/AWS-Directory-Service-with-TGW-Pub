# Configuración de la VPC para la cuenta Stage
resource "aws_vpc" "vpc_stage" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = var.vpc_name
  }
}

# Internet Gateway para la cuenta Stage
resource "aws_internet_gateway" "igw_stage" {
  vpc_id = aws_vpc.vpc_stage.id
  
  tags = {
    Name = var.igw_name_stage
  }
}

# Subnets públicas para la cuenta Stage
resource "aws_subnet" "subnet_stage_public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.vpc_stage.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.subnet_name}-public-${count.index}"
  }
}

# Subnets privadas para la cuenta Stage
resource "aws_subnet" "subnet_stage_private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc_stage.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(var.availability_zones))
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "${var.subnet_name}-private-${count.index}"
  }
}

# Elastic IP para NAT Gateway
resource "aws_eip" "nat_eip_stage" {
  domain = "vpc"
  
  tags = {
    Name = var.eip_name_stage
  }
}

# NAT Gateway para la cuenta Stage
resource "aws_nat_gateway" "nat_gateway_stage" {
  allocation_id = aws_eip.nat_eip_stage.id
  subnet_id     = aws_subnet.subnet_stage_public[0].id
  
  tags = {
    Name = var.natgw_name_stage
  }
}

# Route Table pública para la cuenta Stage
resource "aws_route_table" "rt_stage_public" {
  vpc_id = aws_vpc.vpc_stage.id
  
  tags = {
    Name = var.rt_name_stage_public
  }
}

# Ruta por defecto hacia Internet Gateway
resource "aws_route" "default_route_public" {
  route_table_id         = aws_route_table.rt_stage_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_stage.id
}

# Route Table privada para la cuenta Stage
resource "aws_route_table" "rt_stage_private" {
  vpc_id = aws_vpc.vpc_stage.id
  
  tags = {
    Name = var.rt_name_stage_private
  }
}

# Ruta por defecto hacia NAT Gateway
resource "aws_route" "default_route_private" {
  route_table_id         = aws_route_table.rt_stage_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_stage.id
}

# Asociación de Route Table con Subnets públicas
resource "aws_route_table_association" "rta_stage_public" {
  count          = length(aws_subnet.subnet_stage_public)
  subnet_id      = aws_subnet.subnet_stage_public[count.index].id
  route_table_id = aws_route_table.rt_stage_public.id
}

# Asociación de Route Table con Subnets privadas
resource "aws_route_table_association" "rta_stage_private" {
  count          = length(aws_subnet.subnet_stage_private)
  subnet_id      = aws_subnet.subnet_stage_private[count.index].id
  route_table_id = aws_route_table.rt_stage_private.id
}

# Attachment al Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_stage" {
  subnet_ids             = [for subnet in aws_subnet.subnet_stage_private : subnet.id]
  transit_gateway_id     = var.transit_gateway_id
  vpc_id                 = aws_vpc.vpc_stage.id
  appliance_mode_support = "enable"
  
  tags = {
    Name = var.tgw_attachment_name_stage
  }
}

# Rutas hacia las VPCs de Operaciones a través del Transit Gateway
resource "aws_route" "route_to_operaciones_dev" {
  route_table_id         = aws_route_table.rt_stage_private.id
  destination_cidr_block = var.operaciones_vpc_cidr_dev
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "route_to_operaciones_stage" {
  route_table_id         = aws_route_table.rt_stage_private.id
  destination_cidr_block = var.operaciones_vpc_cidr_stage
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "route_to_operaciones_prod" {
  route_table_id         = aws_route_table.rt_stage_private.id
  destination_cidr_block = var.operaciones_vpc_cidr_prod
  transit_gateway_id     = var.transit_gateway_id
}
