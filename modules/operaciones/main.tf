# Configuración del Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = var.tgw_description
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  auto_accept_shared_attachments  = "enable"
  
  tags = {
    Name = var.tgw_name
  }
}

# Compartir el Transit Gateway con otras cuentas
resource "aws_ram_resource_share" "tgw_share" {
  name                      = var.ram_share_name
  allow_external_principals = true
  
  tags = {
    Name = var.ram_share_name
  }
}

resource "aws_ram_resource_association" "tgw_ram_association" {
  resource_arn       = aws_ec2_transit_gateway.tgw.arn
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}

resource "aws_ram_principal_association" "dev_account" {
  principal          = var.dev_account_id
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}

resource "aws_ram_principal_association" "stage_account" {
  principal          = var.stage_account_id
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}

resource "aws_ram_principal_association" "prod_account" {
  principal          = var.prod_account_id
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}

# VPC para el entorno Dev
resource "aws_vpc" "vpc_operaciones_dev" {
  cidr_block           = var.vpc_cidr_dev
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = var.vpc_name_dev
  }
}

# Internet Gateway para Dev
resource "aws_internet_gateway" "igw_operaciones_dev" {
  vpc_id = aws_vpc.vpc_operaciones_dev.id
  
  tags = {
    Name = var.igw_name_operaciones_dev
  }
}

# Subnets públicas para el entorno Dev
resource "aws_subnet" "subnet_operaciones_dev_public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.vpc_operaciones_dev.id
  cidr_block              = cidrsubnet(var.vpc_cidr_dev, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.subnet_name_dev}-public-${count.index}"
  }
}

# Subnets privadas para el entorno Dev
resource "aws_subnet" "subnet_operaciones_dev_private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc_operaciones_dev.id
  cidr_block        = cidrsubnet(var.vpc_cidr_dev, 8, count.index + length(var.availability_zones))
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "${var.subnet_name_dev}-private-${count.index}"
  }
}

# Elastic IP para NAT Gateway Dev
resource "aws_eip" "nat_eip_dev" {
  domain = "vpc"
  
  tags = {
    Name = var.eip_name_operaciones_dev
  }
}

# NAT Gateway para Dev
resource "aws_nat_gateway" "nat_gateway_dev" {
  allocation_id = aws_eip.nat_eip_dev.id
  subnet_id     = aws_subnet.subnet_operaciones_dev_public[0].id
  
  tags = {
    Name = var.natgw_name_operaciones_dev
  }
}

# VPC para el entorno Stage
resource "aws_vpc" "vpc_operaciones_stage" {
  cidr_block           = var.vpc_cidr_stage
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = var.vpc_name_stage
  }
}

# Internet Gateway para Stage
resource "aws_internet_gateway" "igw_operaciones_stage" {
  vpc_id = aws_vpc.vpc_operaciones_stage.id
  
  tags = {
    Name = var.igw_name_operaciones_stage
  }
}

# Subnets públicas para el entorno Stage
resource "aws_subnet" "subnet_operaciones_stage_public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.vpc_operaciones_stage.id
  cidr_block              = cidrsubnet(var.vpc_cidr_stage, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.subnet_name_stage}-public-${count.index}"
  }
}

# Subnets privadas para el entorno Stage
resource "aws_subnet" "subnet_operaciones_stage_private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc_operaciones_stage.id
  cidr_block        = cidrsubnet(var.vpc_cidr_stage, 8, count.index + length(var.availability_zones))
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "${var.subnet_name_stage}-private-${count.index}"
  }
}

# Elastic IP para NAT Gateway Stage
resource "aws_eip" "nat_eip_stage" {
  domain = "vpc"
  
  tags = {
    Name = var.eip_name_operaciones_stage
  }
}

# NAT Gateway para Stage
resource "aws_nat_gateway" "nat_gateway_stage" {
  allocation_id = aws_eip.nat_eip_stage.id
  subnet_id     = aws_subnet.subnet_operaciones_stage_public[0].id
  
  tags = {
    Name = var.natgw_name_operaciones_stage
  }
}

# VPC para el entorno Prod
resource "aws_vpc" "vpc_operaciones_prod" {
  cidr_block           = var.vpc_cidr_prod
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = var.vpc_name_prod
  }
}

# Internet Gateway para Prod
resource "aws_internet_gateway" "igw_operaciones_prod" {
  vpc_id = aws_vpc.vpc_operaciones_prod.id
  
  tags = {
    Name = var.igw_name_operaciones_prod
  }
}

# Subnets públicas para el entorno Prod
resource "aws_subnet" "subnet_operaciones_prod_public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.vpc_operaciones_prod.id
  cidr_block              = cidrsubnet(var.vpc_cidr_prod, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.subnet_name_prod}-public-${count.index}"
  }
}

# Subnets privadas para el entorno Prod
resource "aws_subnet" "subnet_operaciones_prod_private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc_operaciones_prod.id
  cidr_block        = cidrsubnet(var.vpc_cidr_prod, 8, count.index + length(var.availability_zones))
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "${var.subnet_name_prod}-private-${count.index}"
  }
}

# Elastic IP para NAT Gateway Prod
resource "aws_eip" "nat_eip_prod" {
  domain = "vpc"
  
  tags = {
    Name = var.eip_name_operaciones_prod
  }
}

# NAT Gateway para Prod
resource "aws_nat_gateway" "nat_gateway_prod" {
  allocation_id = aws_eip.nat_eip_prod.id
  subnet_id     = aws_subnet.subnet_operaciones_prod_public[0].id
  
  tags = {
    Name = var.natgw_name_operaciones_prod
  }
}

# Route Tables para cada VPC
# Route Table pública para Dev
resource "aws_route_table" "rt_operaciones_dev_public" {
  vpc_id = aws_vpc.vpc_operaciones_dev.id
  
  tags = {
    Name = var.rt_name_operaciones_dev_public
  }
}

# Ruta por defecto hacia Internet Gateway para Dev
resource "aws_route" "route_dev_public_to_igw" {
  route_table_id         = aws_route_table.rt_operaciones_dev_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_operaciones_dev.id
}

# Route Table privada para Dev
resource "aws_route_table" "rt_operaciones_dev_private" {
  vpc_id = aws_vpc.vpc_operaciones_dev.id
  
  tags = {
    Name = var.rt_name_operaciones_dev_private
  }
}

# Ruta por defecto hacia NAT Gateway para Dev
resource "aws_route" "route_dev_private_to_nat" {
  route_table_id         = aws_route_table.rt_operaciones_dev_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_dev.id
}

# Route Table pública para Stage
resource "aws_route_table" "rt_operaciones_stage_public" {
  vpc_id = aws_vpc.vpc_operaciones_stage.id
  
  tags = {
    Name = var.rt_name_operaciones_stage_public
  }
}

# Ruta por defecto hacia Internet Gateway para Stage
resource "aws_route" "route_stage_public_to_igw" {
  route_table_id         = aws_route_table.rt_operaciones_stage_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_operaciones_stage.id
}

# Route Table privada para Stage
resource "aws_route_table" "rt_operaciones_stage_private" {
  vpc_id = aws_vpc.vpc_operaciones_stage.id
  
  tags = {
    Name = var.rt_name_operaciones_stage_private
  }
}

# Ruta por defecto hacia NAT Gateway para Stage
resource "aws_route" "route_stage_private_to_nat" {
  route_table_id         = aws_route_table.rt_operaciones_stage_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_stage.id
}

# Route Table pública para Prod
resource "aws_route_table" "rt_operaciones_prod_public" {
  vpc_id = aws_vpc.vpc_operaciones_prod.id
  
  tags = {
    Name = var.rt_name_operaciones_prod_public
  }
}

# Ruta por defecto hacia Internet Gateway para Prod
resource "aws_route" "route_prod_public_to_igw" {
  route_table_id         = aws_route_table.rt_operaciones_prod_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_operaciones_prod.id
}

# Route Table privada para Prod
resource "aws_route_table" "rt_operaciones_prod_private" {
  vpc_id = aws_vpc.vpc_operaciones_prod.id
  
  tags = {
    Name = var.rt_name_operaciones_prod_private
  }
}

# Ruta por defecto hacia NAT Gateway para Prod
resource "aws_route" "route_prod_private_to_nat" {
  route_table_id         = aws_route_table.rt_operaciones_prod_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_prod.id
}

# Asociación de Route Tables con Subnets
# Asociaciones para Dev
resource "aws_route_table_association" "rta_operaciones_dev_public" {
  count          = length(aws_subnet.subnet_operaciones_dev_public)
  subnet_id      = aws_subnet.subnet_operaciones_dev_public[count.index].id
  route_table_id = aws_route_table.rt_operaciones_dev_public.id
}

resource "aws_route_table_association" "rta_operaciones_dev_private" {
  count          = length(aws_subnet.subnet_operaciones_dev_private)
  subnet_id      = aws_subnet.subnet_operaciones_dev_private[count.index].id
  route_table_id = aws_route_table.rt_operaciones_dev_private.id
}

# Asociaciones para Stage
resource "aws_route_table_association" "rta_operaciones_stage_public" {
  count          = length(aws_subnet.subnet_operaciones_stage_public)
  subnet_id      = aws_subnet.subnet_operaciones_stage_public[count.index].id
  route_table_id = aws_route_table.rt_operaciones_stage_public.id
}

resource "aws_route_table_association" "rta_operaciones_stage_private" {
  count          = length(aws_subnet.subnet_operaciones_stage_private)
  subnet_id      = aws_subnet.subnet_operaciones_stage_private[count.index].id
  route_table_id = aws_route_table.rt_operaciones_stage_private.id
}

# Asociaciones para Prod
resource "aws_route_table_association" "rta_operaciones_prod_public" {
  count          = length(aws_subnet.subnet_operaciones_prod_public)
  subnet_id      = aws_subnet.subnet_operaciones_prod_public[count.index].id
  route_table_id = aws_route_table.rt_operaciones_prod_public.id
}

resource "aws_route_table_association" "rta_operaciones_prod_private" {
  count          = length(aws_subnet.subnet_operaciones_prod_private)
  subnet_id      = aws_subnet.subnet_operaciones_prod_private[count.index].id
  route_table_id = aws_route_table.rt_operaciones_prod_private.id
}

# Attachments al Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_operaciones_dev" {
  subnet_ids             = [for subnet in aws_subnet.subnet_operaciones_dev_private : subnet.id]
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  vpc_id                 = aws_vpc.vpc_operaciones_dev.id
  appliance_mode_support = "enable"
  
  tags = {
    Name = var.tgw_attachment_name_operaciones_dev
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_operaciones_stage" {
  subnet_ids             = [for subnet in aws_subnet.subnet_operaciones_stage_private : subnet.id]
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  vpc_id                 = aws_vpc.vpc_operaciones_stage.id
  appliance_mode_support = "enable"
  
  tags = {
    Name = var.tgw_attachment_name_operaciones_stage
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_operaciones_prod" {
  subnet_ids             = [for subnet in aws_subnet.subnet_operaciones_prod_private : subnet.id]
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  vpc_id                 = aws_vpc.vpc_operaciones_prod.id
  appliance_mode_support = "enable"
  
  tags = {
    Name = var.tgw_attachment_name_operaciones_prod
  }
}

# Rutas entre VPCs a través del Transit Gateway
# Rutas desde Dev a otras VPCs
resource "aws_route" "route_dev_to_stage" {
  route_table_id         = aws_route_table.rt_operaciones_dev_private.id
  destination_cidr_block = var.vpc_cidr_stage
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_dev_to_prod" {
  route_table_id         = aws_route_table.rt_operaciones_dev_private.id
  destination_cidr_block = var.vpc_cidr_prod
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_dev_to_dev_account" {
  route_table_id         = aws_route_table.rt_operaciones_dev_private.id
  destination_cidr_block = var.vpc_cidr_dev_account
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_dev_to_stage_account" {
  route_table_id         = aws_route_table.rt_operaciones_dev_private.id
  destination_cidr_block = var.vpc_cidr_stage_account
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_dev_to_prod_account" {
  route_table_id         = aws_route_table.rt_operaciones_dev_private.id
  destination_cidr_block = var.vpc_cidr_prod_account
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

# Rutas desde Stage a otras VPCs
resource "aws_route" "route_stage_to_dev" {
  route_table_id         = aws_route_table.rt_operaciones_stage_private.id
  destination_cidr_block = var.vpc_cidr_dev
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_stage_to_prod" {
  route_table_id         = aws_route_table.rt_operaciones_stage_private.id
  destination_cidr_block = var.vpc_cidr_prod
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_stage_to_dev_account" {
  route_table_id         = aws_route_table.rt_operaciones_stage_private.id
  destination_cidr_block = var.vpc_cidr_dev_account
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_stage_to_stage_account" {
  route_table_id         = aws_route_table.rt_operaciones_stage_private.id
  destination_cidr_block = var.vpc_cidr_stage_account
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_stage_to_prod_account" {
  route_table_id         = aws_route_table.rt_operaciones_stage_private.id
  destination_cidr_block = var.vpc_cidr_prod_account
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

# Rutas desde Prod a otras VPCs
resource "aws_route" "route_prod_to_dev" {
  route_table_id         = aws_route_table.rt_operaciones_prod_private.id
  destination_cidr_block = var.vpc_cidr_dev
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_prod_to_stage" {
  route_table_id         = aws_route_table.rt_operaciones_prod_private.id
  destination_cidr_block = var.vpc_cidr_stage
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_prod_to_dev_account" {
  route_table_id         = aws_route_table.rt_operaciones_prod_private.id
  destination_cidr_block = var.vpc_cidr_dev_account
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_prod_to_stage_account" {
  route_table_id         = aws_route_table.rt_operaciones_prod_private.id
  destination_cidr_block = var.vpc_cidr_stage_account
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_prod_to_prod_account" {
  route_table_id         = aws_route_table.rt_operaciones_prod_private.id
  destination_cidr_block = var.vpc_cidr_prod_account
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}
