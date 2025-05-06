# Módulo para la cuenta de Prod

# VPC Prod
resource "aws_vpc" "vpc_prod" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-prod"
  }
}

# Subnets para VPC Prod
resource "aws_subnet" "subnet_prod" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc_prod.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "subnet-prod-${count.index}"
  }
}

# Internet Gateway para permitir conectividad de prueba
resource "aws_internet_gateway" "igw_prod" {
  vpc_id = aws_vpc.vpc_prod.id

  tags = {
    Name = "igw-prod"
  }
}

# Transit Gateway Attachment para VPC Prod
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_prod" {
  subnet_ids                                      = aws_subnet.subnet_prod[*].id
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = aws_vpc.vpc_prod.id
  appliance_mode_support                          = "enable"
  dns_support                                     = "enable"
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = {
    Name = "tgw-attachment-prod"
  }

  # Asegurarse de que el Transit Gateway esté disponible antes de crear el attachment
  depends_on = [aws_vpc.vpc_prod, aws_subnet.subnet_prod]
}

# Tabla de rutas para VPC Prod
resource "aws_route_table" "rt_prod" {
  vpc_id = aws_vpc.vpc_prod.id

  tags = {
    Name = "rt-prod"
  }
}

# Rutas para acceder a los directorios en la cuenta de Operaciones
resource "aws_route" "route_to_operaciones_dev" {
  route_table_id         = aws_route_table.rt_prod.id
  destination_cidr_block = var.operaciones_vpc_cidr_dev
  transit_gateway_id     = var.transit_gateway_id
  
  # Asegurarse de que el Transit Gateway Attachment esté creado antes de configurar las rutas
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_prod]
}

resource "aws_route" "route_to_operaciones_stage" {
  route_table_id         = aws_route_table.rt_prod.id
  destination_cidr_block = var.operaciones_vpc_cidr_stage
  transit_gateway_id     = var.transit_gateway_id
  
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_prod]
}

resource "aws_route" "route_to_operaciones_prod" {
  route_table_id         = aws_route_table.rt_prod.id
  destination_cidr_block = var.operaciones_vpc_cidr_prod
  transit_gateway_id     = var.transit_gateway_id
  
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_prod]
}

# Ruta por defecto para pruebas (opcional, puede comentarse en producción)
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.rt_prod.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_prod.id
}

# Asociación de tablas de rutas con subnets
resource "aws_route_table_association" "rta_prod" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.subnet_prod[count.index].id
  route_table_id = aws_route_table.rt_prod.id
}

# Grupo de seguridad para permitir tráfico desde las VPCs de Operaciones
resource "aws_security_group" "sg_prod" {
  name        = "prod-directory-access"
  description = "Permite trafico para acceder a los servicios de directorio"
  vpc_id      = aws_vpc.vpc_prod.id

  # Permitir todo el tráfico desde las VPCs de Operaciones
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      var.operaciones_vpc_cidr_dev,
      var.operaciones_vpc_cidr_stage,
      var.operaciones_vpc_cidr_prod
    ]
    description = "Trafico desde VPCs de Operaciones"
  }

  # Permitir todo el tráfico saliente
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Trafico saliente"
  }

  tags = {
    Name = "prod-directory-access"
  }
}

# Esperar un tiempo para asegurar que el Transit Gateway Attachment esté completamente creado
resource "time_sleep" "wait_for_tgw_attachment" {
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_prod]
  
  create_duration = "30s"
}
