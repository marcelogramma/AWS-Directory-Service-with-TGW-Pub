# Configuración de los servicios de directorio
# Este archivo contiene la configuración de los servicios de directorio para cada entorno

# Directory Service para Dev
resource "aws_directory_service_directory" "directory_dev" {
  name     = var.directory_name_dev
  password = var.directory_password
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = aws_vpc.vpc_operaciones_dev.id
    subnet_ids = [
      aws_subnet.subnet_operaciones_dev_private[0].id,
      aws_subnet.subnet_operaciones_dev_private[1].id
    ]
  }

  tags = {
    Name = "directory-${var.directory_name_dev}"
    Environment = "Dev"
  }
}

# Directory Service para Stage
resource "aws_directory_service_directory" "directory_stage" {
  name     = var.directory_name_stage
  password = var.directory_password
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = aws_vpc.vpc_operaciones_stage.id
    subnet_ids = [
      aws_subnet.subnet_operaciones_stage_private[0].id,
      aws_subnet.subnet_operaciones_stage_private[1].id
    ]
  }

  tags = {
    Name = "directory-${var.directory_name_stage}"
    Environment = "Stage"
  }
}

# Directory Service para Prod
resource "aws_directory_service_directory" "directory_prod" {
  name     = var.directory_name_prod
  password = var.directory_password
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = aws_vpc.vpc_operaciones_prod.id
    subnet_ids = [
      aws_subnet.subnet_operaciones_prod_private[0].id,
      aws_subnet.subnet_operaciones_prod_private[1].id
    ]
  }

  tags = {
    Name = "directory-${var.directory_name_prod}"
    Environment = "Prod"
  }
}
