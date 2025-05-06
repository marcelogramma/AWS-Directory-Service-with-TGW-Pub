# Security Groups para los Directory Services
# Configuración refactorizada para permitir tráfico desde las cuentas correspondientes

# Esperar a que los servicios de directorio estén disponibles
resource "time_sleep" "wait_for_directory_services" {
  depends_on = [
    aws_directory_service_directory.directory_dev,
    aws_directory_service_directory.directory_stage,
    aws_directory_service_directory.directory_prod
  ]

  create_duration = "60s"
}

# Security Group para la cuenta Dev
resource "aws_security_group" "sg_directory_dev" {
  name        = var.sg_directory_name_dev
  description = "Security group para acceso al Directory Service Dev"
  vpc_id      = aws_vpc.vpc_operaciones_dev.id
  
  tags = {
    Name = var.sg_directory_name_dev
  }
}

# Security Group para la cuenta Stage
resource "aws_security_group" "sg_directory_stage" {
  name        = var.sg_directory_name_stage
  description = "Security group para acceso al Directory Service Stage"
  vpc_id      = aws_vpc.vpc_operaciones_stage.id
  
  tags = {
    Name = var.sg_directory_name_stage
  }
}

# Security Group para la cuenta Prod
resource "aws_security_group" "sg_directory_prod" {
  name        = var.sg_directory_name_prod
  description = "Security group para acceso al Directory Service Prod"
  vpc_id      = aws_vpc.vpc_operaciones_prod.id
  
  tags = {
    Name = var.sg_directory_name_prod
  }
}

# Reglas para permitir tráfico desde la cuenta Dev al Directory Service Dev
resource "aws_security_group_rule" "sg_directory_dev_allow_dev_account_tcp" {
  security_group_id = aws_security_group.sg_directory_dev.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_dev_account]
  description       = "Allow all TCP traffic from Dev account"
}

resource "aws_security_group_rule" "sg_directory_dev_allow_dev_account_udp" {
  security_group_id = aws_security_group.sg_directory_dev.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "udp"
  cidr_blocks       = [var.vpc_cidr_dev_account]
  description       = "Allow all UDP traffic from Dev account"
}

resource "aws_security_group_rule" "sg_directory_dev_allow_dev_account_icmp" {
  security_group_id = aws_security_group.sg_directory_dev.id
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [var.vpc_cidr_dev_account]
  description       = "Allow all ICMP traffic from Dev account"
}

# Reglas para permitir tráfico desde la cuenta Stage al Directory Service Stage
resource "aws_security_group_rule" "sg_directory_stage_allow_stage_account_tcp" {
  security_group_id = aws_security_group.sg_directory_stage.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_stage_account]
  description       = "Allow all TCP traffic from Stage account"
}

resource "aws_security_group_rule" "sg_directory_stage_allow_stage_account_udp" {
  security_group_id = aws_security_group.sg_directory_stage.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "udp"
  cidr_blocks       = [var.vpc_cidr_stage_account]
  description       = "Allow all UDP traffic from Stage account"
}

resource "aws_security_group_rule" "sg_directory_stage_allow_stage_account_icmp" {
  security_group_id = aws_security_group.sg_directory_stage.id
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [var.vpc_cidr_stage_account]
  description       = "Allow all ICMP traffic from Stage account"
}

# Reglas para permitir tráfico desde la cuenta Prod al Directory Service Prod
resource "aws_security_group_rule" "sg_directory_prod_allow_prod_account_tcp" {
  security_group_id = aws_security_group.sg_directory_prod.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_prod_account]
  description       = "Allow all TCP traffic from Prod account"
}

resource "aws_security_group_rule" "sg_directory_prod_allow_prod_account_udp" {
  security_group_id = aws_security_group.sg_directory_prod.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "udp"
  cidr_blocks       = [var.vpc_cidr_prod_account]
  description       = "Allow all UDP traffic from Prod account"
}

resource "aws_security_group_rule" "sg_directory_prod_allow_prod_account_icmp" {
  security_group_id = aws_security_group.sg_directory_prod.id
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [var.vpc_cidr_prod_account]
  description       = "Allow all ICMP traffic from Prod account"
}

# Reglas de egreso para todos los security groups
resource "aws_security_group_rule" "sg_directory_dev_egress" {
  security_group_id = aws_security_group.sg_directory_dev.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

resource "aws_security_group_rule" "sg_directory_stage_egress" {
  security_group_id = aws_security_group.sg_directory_stage.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

resource "aws_security_group_rule" "sg_directory_prod_egress" {
  security_group_id = aws_security_group.sg_directory_prod.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}
