output "vpc_id" {
  description = "Identificador de la VPC generada"
  value       = module.vpc_module.vpc_id
}

output "subnets_id" {
  description = "Identificadores de las subnets creadas"
  value = {
    for subnet_name, subnet_values in module.subnet_module :
    subnet_name => subnet_values.subnet_id
  }
}

output "security_groups_id" {
  description = "Identificadores de los grupos de seguridad creados"
  value = {
    for security_group_name, security_group_values in module.security_groups_module :
    security_group_name => security_group_values.sg_group_id
  }
}

output "transit_gateway_cidr_blocks" {
  description = "Mapa que asocia el identificador de la subnet con los bloques CIDR a los que tiene rutas"
  value = {
    for subnet_name, cird_blocks in var.transit_gateway_cidr_blocks :
    module.subnet_module[subnet_name].subnet_id => cird_blocks
  }
}

output "transit_gateway_attachment_id" {
  description = "Identificador de la asociación creada con el Transit Gateway"
  value       = var.transit_gateway_id != null ? aws_ec2_transit_gateway_vpc_attachment.transit_gateway_vpc_attachment[0].id : ""
}