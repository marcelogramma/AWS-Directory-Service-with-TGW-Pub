# Configuración para agregar reglas de seguridad a los ENIs de los Directory Services
# Este archivo agrega reglas de seguridad a los security groups creados automáticamente por AWS Directory Service

# Esperar a que los servicios de directorio estén completamente disponibles
resource "time_sleep" "wait_for_directory_enis" {
  depends_on = [
    aws_directory_service_directory.directory_dev,
    aws_directory_service_directory.directory_stage,
    aws_directory_service_directory.directory_prod,
    time_sleep.wait_for_directory_services
  ]

  # Esperar un tiempo adicional para asegurar que los ENIs estén disponibles
  create_duration = "90s"
}

# Definición de los puertos específicos requeridos por AWS Directory Service
locals {
  directory_service_ports = {
    # DNS
    dns_tcp = {
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      description = "DNS (TCP)"
    },
    dns_udp = {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      description = "DNS (UDP)"
    },
    # Kerberos
    kerberos_tcp = {
      from_port   = 88
      to_port     = 88
      protocol    = "tcp"
      description = "Kerberos (TCP)"
    },
    kerberos_udp = {
      from_port   = 88
      to_port     = 88
      protocol    = "udp"
      description = "Kerberos (UDP)"
    },
    # LDAP
    ldap_tcp = {
      from_port   = 389
      to_port     = 389
      protocol    = "tcp"
      description = "LDAP (TCP)"
    },
    ldap_udp = {
      from_port   = 389
      to_port     = 389
      protocol    = "udp"
      description = "LDAP (UDP)"
    },
    # SMB/CIFS
    smb_tcp = {
      from_port   = 445
      to_port     = 445
      protocol    = "tcp"
      description = "SMB/CIFS (TCP)"
    },
    # LDAPS
    ldaps_tcp = {
      from_port   = 636
      to_port     = 636
      protocol    = "tcp"
      description = "LDAPS (TCP)"
    },
    # Kerberos password change
    kerberos_pw_tcp = {
      from_port   = 464
      to_port     = 464
      protocol    = "tcp"
      description = "Kerberos password change (TCP)"
    },
    kerberos_pw_udp = {
      from_port   = 464
      to_port     = 464
      protocol    = "udp"
      description = "Kerberos password change (UDP)"
    },
    # Global Catalog
    gc_tcp = {
      from_port   = 3268
      to_port     = 3269
      protocol    = "tcp"
      description = "Global Catalog (TCP)"
    },
    # NTP
    ntp_udp = {
      from_port   = 123
      to_port     = 123
      protocol    = "udp"
      description = "NTP (UDP)"
    },
    # RPC
    rpc_tcp = {
      from_port   = 135
      to_port     = 135
      protocol    = "tcp"
      description = "RPC (TCP)"
    },
    # ICMP (ping)
    icmp = {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "ICMP (ping)"
    },
    # Puertos efímeros para RPC (TCP)
    ephemeral_tcp = {
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      description = "Ephemeral ports for RPC (TCP)"
    },
    # Puertos efímeros para RPC (UDP)
    ephemeral_udp = {
      from_port   = 1024
      to_port     = 65535
      protocol    = "udp"
      description = "Ephemeral ports for RPC (UDP)"
    }
  }
}

# Reglas para el security group del Directory Service Dev
resource "aws_security_group_rule" "directory_dev_eni_rules" {
  for_each = local.directory_service_ports

  security_group_id = aws_directory_service_directory.directory_dev.security_group_id
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = [var.vpc_cidr_dev_account]
  description       = "${each.value.description} from Dev account"
  
  depends_on = [time_sleep.wait_for_directory_enis]
}

# Reglas para el security group del Directory Service Stage
resource "aws_security_group_rule" "directory_stage_eni_rules" {
  for_each = local.directory_service_ports

  security_group_id = aws_directory_service_directory.directory_stage.security_group_id
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = [var.vpc_cidr_stage_account]
  description       = "${each.value.description} from Stage account"
  
  depends_on = [time_sleep.wait_for_directory_enis]
}

# Reglas para el security group del Directory Service Prod
resource "aws_security_group_rule" "directory_prod_eni_rules" {
  for_each = local.directory_service_ports

  security_group_id = aws_directory_service_directory.directory_prod.security_group_id
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = [var.vpc_cidr_prod_account]
  description       = "${each.value.description} from Prod account"
  
  depends_on = [time_sleep.wait_for_directory_enis]
}

# Outputs para verificar los IDs de los security groups de los ENIs
output "directory_dev_eni_security_group_id" {
  description = "ID del security group del ENI del Directory Service Dev"
  value       = aws_directory_service_directory.directory_dev.security_group_id
}

output "directory_stage_eni_security_group_id" {
  description = "ID del security group del ENI del Directory Service Stage"
  value       = aws_directory_service_directory.directory_stage.security_group_id
}

output "directory_prod_eni_security_group_id" {
  description = "ID del security group del ENI del Directory Service Prod"
  value       = aws_directory_service_directory.directory_prod.security_group_id
}
