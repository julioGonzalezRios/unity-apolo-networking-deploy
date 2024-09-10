# Se especifica la versión del proveedore AWS necesario para este código.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Se configura el proveedor AWS, especificando la región y el profile.
provider "aws" {
  region  = var.region
  profile = var.profile
}

locals {

  # Se agregan los tags de Date/Time y Environment
  tags = merge(var.tags, {
    "Date/Time"   = timeadd(timestamp(), "-6h")
    "Environment" = var.environment
  })

  # Se crea una lista que definirá cuantas tablas de rutas privadas habrá, esto se hace a partir de
  # identificar si una subnet privada tiene rutas  hacia el Transit Gateway ('var.transit_gateway_cidr_blocks').
  # En caso de que una subnet no tenga ninguna ruta hacia un destino específicado, se le asignará
  # la tabla de ruteo principal, que solo contiene la ruta hacia la misma VPC.
  private_route_table_definition = [
    for subnet_name, subnet_values in var.subnets :
    subnet_name
    if contains(keys(var.transit_gateway_cidr_blocks), subnet_name)
  ]

  # Se crea una estructura a partir de 'var.transit_gateway_cidr_blocks', que indicará cuantas rutas serán
  # necesarias crear hacia el Transit Gateway.
  subnets_transit_cidr_blocks_list = flatten([
    for subnet_name, cidr_blocks in var.transit_gateway_cidr_blocks : [
      for cidr_block in cidr_blocks : {
        subnet_name = subnet_name
        cidr_block  = cidr_block
      }
    ]
  ])

  # Se crea un mapa a partir de 'local.subnets_transit_cidr_blocks_list' para poder identificar
  # los valores por medio de una llave que se construye a partir de la subnet privada que requiere la ruta
  # y la ruta destino hacia el Transit Gateway.
  subnets_transit_cidr_blocks = {
    for values in local.subnets_transit_cidr_blocks_list :
    "${values.subnet_name}-${values.cidr_block}" => values
  }

  # Se crea una lista de las subntes privadas que tendrán conexión directa con el Transit Gateway
  subnets_transit_gateway = [
    for subnet_name, subnet_values in var.subnets :
    subnet_name
    if(subnet_values.transit_gateway_direct_connection)
  ]

  # Se crea una lista de las subntes privadas que contendrán el NAT Gateway
  route_tables_nat_gateway = toset([
    for subnet_name in var.nat_gateway_subnets :
    "to-${subnet_name}"
  ])

  routes_nat_cidr_blocks_list = flatten([
    for nat_gateway_subnet, cidr_blocks in var.nat_gateway_cidr_blocks : [
      for cidr_block in cidr_blocks : {
        nat_gateway = nat_gateway_subnet
        route_table = "to-${nat_gateway_subnet}"
        cidr_block  = cidr_block
      }
    ]
  ])

  routes_nat_cidr_blocks = {
    for values in local.routes_nat_cidr_blocks_list :
    "${values.route_table}${values.cidr_block}" => values
  }

  # Se crea una lista de las subntes privadas que tendrán rutas a través del NAT Gateway
  subnets_nat_gateway = [
    for subnet_name, subnet_values in var.subnets :
    subnet_name
    if(subnet_values.nat_gateway_name != null)
  ]

  # Se crea una estructura a partir de 'var.security_groups',  la cual contendrá cada una de las reglas de ingreso
  # de los security groups definidos, esto para poder crear y asociar las reglas posteriormente a la creación de los
  # security groups en caso de que exista una dependencia entre ellos.
  ingress_rules_list = flatten([
    for security_group_name, security_group_values in var.security_groups : [
      for ingress_rule in security_group_values.ingress : {
        security_group_name = security_group_name
        ingress_rule        = ingress_rule
        name_aux1           = ingress_rule.security_group_name != null ? ingress_rule.security_group_name : ""
        name_aux2           = ingress_rule.cidr_blocks != null ? ingress_rule.cidr_blocks[0] : ""
        name_aux3           = ingress_rule.self != null ? ingress_rule.self : ""
      }
    ]
  ])

  # Se crea un mapa a partir de 'local.ingress_rules_listt' para poder identificar
  # los valores por medio de una llave que se construye a partir del security group que requiere la regla de ingreso,
  # el puerto fuente el puerto destino, el protocolo y cadena auxliares
  ingress_rule = {
    for values in local.ingress_rules_list :
    "${values.security_group_name}-${values.ingress_rule.from_port}-${values.ingress_rule.to_port}-${values.ingress_rule.protocol}-${values.name_aux1}-${values.name_aux2}-${values.name_aux3}" => values
  }

  # Se crea una estructura a partir de 'var.security_groups',  la cual contendrá cada una de las reglas de egreso
  # de los security groups definidos, esto para poder crear y asociar las reglas posteriormente a la creación de los
  # security groups en caso de que exista una dependencia entre ellos.
  egress_rules_list = flatten([
    for security_group_name, security_group_values in var.security_groups : [
      for egress_rule in security_group_values.egress : {
        security_group_name = security_group_name
        egress_rule         = egress_rule
        name_aux1           = egress_rule.security_group_name != null ? egress_rule.security_group_name : ""
        name_aux2           = egress_rule.cidr_blocks != null ? egress_rule.cidr_blocks[0] : ""
        name_aux3           = egress_rule.self != null ? egress_rule.self : ""
      }
    ]
  ])

  # Se crea un mapa a partir de 'local.egress_rules_listt' para poder identificar
  # los valores por medio de una llave que se construye a partir del security group que requiere la regla de egreso,
  # el puerto fuente el puerto destino, el protocolo y cadena auxliares
  egress_rule = {
    for values in local.egress_rules_list :
    "${values.security_group_name}-${values.egress_rule.from_port}-${values.egress_rule.to_port}-${values.egress_rule.protocol}-${values.name_aux1}-${values.name_aux2}-${values.name_aux3}" => values
  }
}

# Crea una VPC utilizando el módulo 'Unity-VPC-module' y en caso de existir subnet públicas, crea y asocia a la VPC
# un Internet Gateway
module "vpc_module" {
  source                    = "git::https://github.com/SF-Bancoppel/unity-vpc-module.git?ref=v1.0.0"
  vpc_cidr_block            = var.vpc.cidr_block
  internet_gateway_creation = false
  partial_name              = var.vpc.name
  environment               = var.environment
  tags                      = local.tags
}

# Asocia las subnets extra a la VPC creada, estas subnets se especifican en 'var.vpc.extra_cidr_blocks'
resource "aws_vpc_ipv4_cidr_block_association" "extra_vpc_ipv4_cidr_block_association" {
  for_each   = var.vpc_cidr_blocks
  vpc_id     = module.vpc_module.vpc_id
  cidr_block = each.key
}

# Crea una serie de subnets especificadas en 'var.subnets' utilizando el módulo 'Unity-SubNet-module'
module "subnet_module" {
  source                   = "git::https://github.com/SF-Bancoppel/unity-subnet-module.git?ref=v1.0.0"
  for_each                 = var.subnets
  vpc_id                   = module.vpc_module.vpc_id
  subnet_cidr_block        = each.value.cidr_block
  subnet_availability_zone = each.value.availability_zone
  subnet_type              = "private"
  partial_name             = "${var.vpc.name}-${each.key}"
  environment              = var.environment
  # Se agregan los tags para desplegar el Load Balancer a las subnets de los eks
  tags = can(regex("eks", each.key)) ? merge({
    "kubernetes.io/role/internal-elb"          = "1"
    "kubernetes.io/cluster/bcpl-eks-dev-apolo" = "owned"
  }, local.tags) : local.tags

  depends_on = [aws_vpc_ipv4_cidr_block_association.extra_vpc_ipv4_cidr_block_association]
}

# Crea los grupos de seguridad especificados en 'var.security_groups' utilizando el módulo 'Unity-SecurityGroups-module'
# Estos serán asociados a la VPC especificadada en 'module.vpc_module.vpc_id', los grupos de seguridad se crearán sin reglas
# asociadas, ya que si hay reglas que dependen de grupos de seguridad dentro de la VPC es necesario su previa creación.
module "security_groups_module" {
  source   = "git::https://github.com/SF-Bancoppel/unity-securitygroups-module.git?ref=v1.0.0"
  for_each = var.security_groups
  vpc_id   = module.vpc_module.vpc_id
  security_group_config = {
    name        = each.value.name
    description = each.value.description
    ingress     = []
    egress      = []
  }
  partial_name = each.value.name
  environment  = var.environment
  tags         = local.tags
}


# Se crean las reglas de ingreso de los grupos de seguridad
resource "aws_security_group_rule" "ingress_security_group_rule" {
  for_each                 = local.ingress_rule
  type                     = "ingress"
  from_port                = each.value.ingress_rule.from_port
  to_port                  = each.value.ingress_rule.to_port
  protocol                 = each.value.ingress_rule.protocol
  cidr_blocks              = each.value.ingress_rule.cidr_blocks
  self                     = each.value.ingress_rule.self
  source_security_group_id = each.value.ingress_rule.security_group_name != null ? module.security_groups_module[each.value.ingress_rule.security_group_name].sg_group_id : null
  description              = each.value.ingress_rule.description
  security_group_id        = module.security_groups_module[each.value.security_group_name].sg_group_id
}


# Se crean las reglas de egreso de los grupos de seguridad
resource "aws_security_group_rule" "egress_security_group_rule" {
  for_each                 = local.egress_rule
  type                     = "egress"
  from_port                = each.value.egress_rule.from_port
  to_port                  = each.value.egress_rule.to_port
  protocol                 = each.value.egress_rule.protocol
  cidr_blocks              = each.value.egress_rule.cidr_blocks
  self                     = each.value.egress_rule.self
  source_security_group_id = each.value.egress_rule.security_group_name != null ? module.security_groups_module[each.value.egress_rule.security_group_name].sg_group_id : null
  description              = each.value.egress_rule.description
  security_group_id        = module.security_groups_module[each.value.security_group_name].sg_group_id
}

# Crea una asociación de la VPC y las subnets de la misma con el Transit Gateway definido por el identificador de la variable
# 'var.transit_gateway_id', para la creación de este, debe de existir al menos una subnet que se con conexión directa
resource "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_vpc_attachment" {
  count  = var.transit_gateway_id != null ? 1 : 0
  vpc_id = module.vpc_module.vpc_id
  subnet_ids = [
    for subnet_name, subnet_values in module.subnet_module :
    subnet_values.subnet_id if contains(local.subnets_transit_gateway, subnet_name)
  ]
  transit_gateway_id = var.transit_gateway_id

  # Define las etiquetas incluyendo una etiqueta 'Name'
  tags = merge(local.tags, {
    "Name"         = "bcpl-tgw-attachment-${var.environment}-${var.vpc.name}",
    "Service Name" = "tgwa",
  })

  # Ignora los cambias en la etiqueta 'Date/Time', dado que esta solo se considera al momento de la creación de los recursos
  lifecycle {
    ignore_changes = [tags["Date/Time"]]
  }
}

# Crea la tabla de ruteo principal de la VPC, a esta tabla se asociarán las subnets que no requieran una tabla
# de ruteo con rutas fuera de la VPC
resource "aws_default_route_table" "main_route_table" {
  default_route_table_id = module.vpc_module.default_route_table_id
  # Define las etiquetas incluyendo una etiqueta 'Name' y ''Service Name'
  tags = merge(local.tags, {
    "Name"         = "bcpl-rtb-${var.environment}-${var.vpc.name}",
    "Service Name" = "rtb",
  })
  # Ignora los cambias en la etiqueta 'Date/Time', dado que esta solo se considera al momento de la creación de los recursos
  lifecycle {
    ignore_changes = [tags["Date/Time"]]
  }
  # Especifica una dependencia explícita con la VPC garantizando
  # que se cree el recurso posterior a las dependencias.
  depends_on = [
    module.vpc_module,
  ]
}


# Crea las tablas de rutas para las subnets privadas a partir de 'local.private_route_table_definition'
# y la asocia a la VPC creada en el modulo 'Unity-VPC-module'.
resource "aws_route_table" "private_route_table" {
  for_each = toset(local.private_route_table_definition)
  vpc_id   = module.vpc_module.vpc_id
  # Define las etiquetas para la tabla de rutas, incluyendo una etiqueta 'Name'.
  tags = merge(local.tags, {
    "Name"         = "bcpl-rtb-${var.environment}-${var.vpc.name}-${each.key}",
    "Service Name" = "rtb",
  })
  # Ignora los cambias en la etiqueta 'Date/Time', dado que esta solo se considera al momento de la creación de los recursos
  lifecycle {
    ignore_changes = [tags["Date/Time"]]
  }
  # Especifica una dependencia explícita con la VPC garantizando que se cree el recurso posterior a dicha dependencia.
  depends_on = [module.vpc_module]
}


# Crea las rutas para las subnets privadas hacia los bloques de CIDR que ser dirigidos al Transit Gateway y se agregan a  las tablas
# de las subnets privadas. Las rutas estan definidos en 'local.subnets_transit_cidr_blocks'.
resource "aws_route" "transit_route" {
  for_each               = local.subnets_transit_cidr_blocks
  route_table_id         = aws_route_table.private_route_table[each.value.subnet_name].id
  destination_cidr_block = each.value.cidr_block
  transit_gateway_id     = var.transit_gateway_id
  # Especifica una dependencia explícita con la tabla de rutas  garantizando que se cree el
  # recurso posterior a dicha dependencia.
  depends_on = [
    aws_route_table.private_route_table,
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_vpc_attachment
  ]
}

# Asocia cada subnet privada con su respectiva tabla de rutas
resource "aws_route_table_association" "private_route_table_association" {
  for_each       = toset(local.private_route_table_definition)
  subnet_id      = module.subnet_module[each.key].subnet_id
  route_table_id = aws_route_table.private_route_table[each.key].id
  # Especifica una dependencia explícita con las subnets y la tabla de rutas  garantizando que se cree el
  # recurso posterior a dicha dependencia.
  depends_on = [
    module.subnet_module,
    aws_route_table.private_route_table
  ]
}

# Crea un NAT Gateway en las subnets donde se indicó
resource "aws_nat_gateway" "private_nat_gateway" {
  for_each          = var.nat_gateway_subnets
  connectivity_type = "private"
  subnet_id         = module.subnet_module[each.value].subnet_id
  # Define las etiquetas incluyendo una etiqueta 'Name' y 'Service Name'
  tags = merge(local.tags, {
    "Name"         = "bcpl-nat-${var.environment}-${var.vpc.name}-${each.value}",
    "Service Name" = "nat",
  })
  # Ignora los cambias en la etiqueta 'Date/Time', dado que esta solo se considera al momento de la creación de los recursos
  lifecycle {
    ignore_changes = [tags["Date/Time"]]
  }
}

# Crea las tablas de rutas para las subnets privadas a partir de 'local.nat_gateway'
# y la asocia a la VPC creada en el modulo 'Unity-VPC-module'.
resource "aws_route_table" "nat_route_table" {
  for_each = local.route_tables_nat_gateway
  vpc_id   = module.vpc_module.vpc_id
  # Define las etiquetas para la tabla de rutas, incluyendo una etiqueta 'Name' y 'Service Name'
  tags = merge(local.tags, {
    "Name"         = "bcpl-rtb-${var.environment}-${var.vpc.name}-${each.value}",
    "Service Name" = "rtb",
  })
  # Ignora los cambias en la etiqueta 'Date/Time', dado que esta solo se considera al momento de la creación de los recursos
  lifecycle {
    ignore_changes = [tags["Date/Time"]]
  }
  # Especifica una dependencia explícita con la VPC garantizando que se cree el recurso posterior a dicha dependencia.
  depends_on = [module.vpc_module]
}

# Crea las rutas para dirigir todo el trafico para las subnets privadas hacia los NAT Gateway
resource "aws_route" "nat_route" {
  for_each               = local.routes_nat_cidr_blocks
  route_table_id         = aws_route_table.nat_route_table[each.value.route_table].id
  destination_cidr_block = each.value.cidr_block
  nat_gateway_id         = aws_nat_gateway.private_nat_gateway[each.value.nat_gateway].id
  # Especifica una dependencia explícita con la tabla de rutas  garantizando que se cree el
  # recurso posterior a dicha dependencia.
  depends_on = [
    aws_route_table.nat_route_table,
  ]
}


# Asocia cada subnet privada de los NAT con su respectiva tabla de rutas
resource "aws_route_table_association" "nat_route_table_association" {
  for_each       = toset(local.subnets_nat_gateway)
  subnet_id      = module.subnet_module[each.key].subnet_id
  route_table_id = aws_route_table.nat_route_table["to-${lookup(var.subnets[each.key], "nat_gateway_name", null)}"].id
  # Especifica una dependencia explícita con las subnets y la tabla de rutas  garantizando que se cree el
  # recurso posterior a dicha dependencia.
  depends_on = [
    module.subnet_module,
    aws_route_table.private_route_table
  ]
}

# Se crea tablas de rutas extras para subnets especificadas
resource "aws_route_table" "extra_route_tables" {
  for_each = var.extra_route_tables
  vpc_id   = module.vpc_module.vpc_id
  # Define las etiquetas para la tabla de rutas, incluyendo una etiqueta 'Name'.
  tags = merge(local.tags, {
    "Name"         = "bcpl-rtb-${var.environment}-${var.vpc.name}-${each.key}",
    "Service Name" = "rtb",
  })
  # Ignora los cambias en la etiqueta 'Date/Time', dado que esta solo se considera al momento de la creación de los recursos
  lifecycle {
    ignore_changes = [tags["Date/Time"]]
  }
  # Especifica una dependencia explícita con la VPC garantizando que se cree el recurso posterior a dicha dependencia.
  depends_on = [module.vpc_module]
}

# Asocia cada tabla de rutas extra con su respectiva subnet
resource "aws_route_table_association" "extra_route_table_association" {
  for_each       = var.extra_route_tables
  subnet_id      = module.subnet_module[each.key].subnet_id
  route_table_id = aws_route_table.extra_route_tables[each.key].id
  # Especifica una dependencia explícita con las subnets y la tabla de rutas  garantizando que se cree el
  # recurso posterior a dicha dependencia.
  depends_on = [
    module.subnet_module,
    aws_route_table.extra_route_tables
  ]
}