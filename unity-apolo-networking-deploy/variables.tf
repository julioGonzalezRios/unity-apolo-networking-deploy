variable "profile" {
  description = "Nombre de perfil para el despliegue de la infraestructura"
  type        = string
}

variable "region" {
  description = "Región en la que se desplegarán los recursos AWS"
  type        = string
}

variable "transit_gateway_id" {
  description = "Identificador del Transit Gateway que se asociará a la VPC"
  type        = string
  default     = null
}

variable "vpc" {
  description = "Estructura que contendrá el nombre y el bloque CIDR de la VPC"
  type = object({
    name       = string
    cidr_block = string
  })
}

variable "subnets" {
  description = "Estructura que contedrá las subnets en forma de objeto que serán creadas en la configuración, se especifica como llave de cada objeto el nombre de la subnet y dentro de cada objeto se especifica el correspondiente bloque CIDR, la availability zone, tipo de Subnet, si dicha Subnet tiene acceso a internet y si la Subnte tiene conexión directa con el Transit Gateway"
  type = map(object({
    cidr_block                        = string
    availability_zone                 = string
    transit_gateway_direct_connection = bool
    nat_gateway_name                  = string
  }))
}

variable "security_groups" {
  description = "Mapa de los grupos de seguridad que se crearán para la VPC, cada grupo de seguridad está representado por un objeto con los campos de nombre, descripción, reglas de tráfico entrante (ingress) y reglas de tráfico saliente (egress)"
  type = map(object({
    name        = string
    description = string
    ingress = set(object({
      from_port           = number
      to_port             = number
      protocol            = string
      cidr_blocks         = list(string)
      self                = bool
      security_group_name = string
      description         = string
    }))
    egress = set(object({
      from_port           = number
      to_port             = number
      protocol            = string
      cidr_blocks         = list(string)
      self                = bool
      security_group_name = string
      description         = string
    }))
  }))
}

variable "transit_gateway_cidr_blocks" {
  description = "Mapa de bloques CIRD que necesitan rutas de acceso al Transit Gateway"
  type        = map(set(string))
  default     = {}
}

variable "vpc_cidr_blocks" {
  description = "CIDR Blocks que se asociarán a la VPC"
  type        = set(string)
  default     = []
}

variable "nat_gateway_subnets" {
  description = ""
  type        = set(string)
  default     = []
}

variable "nat_gateway_cidr_blocks" {
  description = ""
  type        = map(set(string))
  default     = {}
}

variable "environment" {
  description = "Variable utilizada para el nombrado estándar de los recursos"
  type        = string
}

variable "tags" {
  description = "Etiquetas base para los recursos, adicionalmente se asignará la etiqueta Name"
  type        = map(string)
}

variable "extra_route_tables" {
  description = "Tabals de rutas adicionales que se crearán en la VPC"
  type        = set(string)
}