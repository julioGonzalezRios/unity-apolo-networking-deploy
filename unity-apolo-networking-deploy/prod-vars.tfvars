# Region en la que se desplegaran los recursos
region = "us-east-1"


# Se define el bloque de IP que se utilizara para la creacion de la VPC
# Se define el nombre de la VPC
vpc = {
  cidr_block = "10.208.20.0/22"
  name       = "apolo"
}

# Se definen los bloques de IP adicionales que se utilizaran para la creacion de la VPC
vpc_cidr_blocks = ["100.64.0.0/16"]

# Se define el ambiente en el que se desplegaran los recursos
environment = "prod"

# Se definen las etiquetas que se utilizaran para los recursos
tags = {
  "Application Role" = "networking",
  "Project"          = "Unity",
  "Owner"            = "Rafael Menezes",
  "Cost Center"      = "232020 MHGO NVO CORE",
  "Business Unit"    = "Apolo",
  "Version"          = "1.0"
}

# Se definen los bloques de IP que se utilizaran para la creacion de las subredes
subnets = {
  eks-control-plane-a = {
    availability_zone                 = "us-east-1a"
    cidr_block                        = "10.208.20.0/27"
    transit_gateway_direct_connection = true
    nat_gateway_name                  = null
  }

  eks-control-plane-b = {
    availability_zone                 = "us-east-1b"
    cidr_block                        = "10.208.20.32/27"
    transit_gateway_direct_connection = true
    nat_gateway_name                  = null
  }

  eks-control-plane-c = {
    availability_zone                 = "us-east-1c"
    cidr_block                        = "10.208.20.64/27"
    transit_gateway_direct_connection = true
    nat_gateway_name                  = null
  }

  nlb-nat-eks-a = {
    availability_zone                 = "us-east-1a"
    cidr_block                        = "10.208.20.96/27"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  nlb-nat-eks-b = {
    availability_zone                 = "us-east-1b"
    cidr_block                        = "10.208.20.128/27"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  nlb-nat-eks-c = {
    availability_zone                 = "us-east-1c"
    cidr_block                        = "10.208.20.160/27"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  yugabytedb-a = {
    availability_zone                 = "us-east-1a"
    cidr_block                        = "10.208.20.192/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  yugabytedb-b = {
    availability_zone                 = "us-east-1b"
    cidr_block                        = "10.208.20.208/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  yugabytedb-c = {
    availability_zone                 = "us-east-1c"
    cidr_block                        = "10.208.20.224/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  webmethods-a = {
    availability_zone                 = "us-east-1a"
    cidr_block                        = "10.208.20.240/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  webmethods-b = {
    availability_zone                 = "us-east-1b"
    cidr_block                        = "10.208.21.0/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  webmethods-c = {
    availability_zone                 = "us-east-1c"
    cidr_block                        = "10.208.21.16/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  rds-oracle-a = {
    availability_zone                 = "us-east-1a"
    cidr_block                        = "10.208.21.32/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  rds-oracle-b = {
    availability_zone                 = "us-east-1b"
    cidr_block                        = "10.208.21.48/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  elc-redis-a = {
    availability_zone                 = "us-east-1a"
    cidr_block                        = "10.208.21.64/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  elc-redis-b = {
    availability_zone                 = "us-east-1b"
    cidr_block                        = "10.208.21.80/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  elc-redis-c = {
    availability_zone                 = "us-east-1c"
    cidr_block                        = "10.208.21.96/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  eks-node-a = {
    availability_zone                 = "us-east-1a"
    cidr_block                        = "100.64.0.0/18"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  eks-node-b = {
    availability_zone                 = "us-east-1b"
    cidr_block                        = "100.64.64.0/18"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  eks-node-c = {
    availability_zone                 = "us-east-1c"
    cidr_block                        = "100.64.128.0/18"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }
}

# Se definen las reglas de seguridad que se utilizaran para la creacion de los grupos de seguridad
security_groups = {
  eks-sg = {
    name        = "apolo-eks-node-group"
    description = "Security Group para nodos de EKS"
    ingress = [
      {
        from_port           = 0
        to_port             = 65535
        protocol            = "tcp"
        cidr_blocks         = null
        self                = true
        security_group_name = null
        description         = "Permite la comunicacion TCP entre los nodos del EKS"
      },
      {
        from_port           = 0
        to_port             = 65535
        protocol            = "udp"
        cidr_blocks         = null
        self                = true
        security_group_name = null
        description         = "Permite la comunicacion UDP entre los nodos del EKS"
      },
      {
        from_port           = 22
        to_port             = 22
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion SSH"
      },
      {
        from_port           = 80
        to_port             = 80
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion HTTP desde el Load balancer"
      },
      {
        from_port           = 443
        to_port             = 443
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion desde el Transit Gateway"
      },
      {
        from_port           = 8080
        to_port             = 8080
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion HTTP (alternativa)"
      }
    ]
    egress = [
      {
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la salida hacia el Transit Gateway"
      }
    ]
  }
  yugabytedb-sg = {
    name        = "apolo-yugabytedb"
    description = "Security Group para YUGABYTEDB"
    ingress = [
      {
        from_port           = 22
        to_port             = 22
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion SHH"
      },
      {
        from_port           = 80
        to_port             = 80
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion HTTP"
      },
      {
        from_port           = 443
        to_port             = 443
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion HTTPS"
      },
      {
        from_port           = 8080
        to_port             = 8080
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion HTTP (alternativa)"
      },
      {
        from_port           = 8800
        to_port             = 8800
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion HTTP (replicacion)"
      },
      {
        from_port           = 54422
        to_port             = 54422
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion SSH (para el universo de nodos)"
      },
      {
        from_port           = 7000
        to_port             = 7000
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion con el Admin Portal de YugabyteDB"
      },
      {
        from_port           = 7100
        to_port             = 7100
        protocol            = "tcp"
        cidr_blocks         = null
        self                = true
        security_group_name = null
        description         = "Permite la comunicacion RCP interna entre los nodos"
      },
      {
        from_port           = 9000
        to_port             = 9000
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion con el Admin del WebServer de YugabyteDB"
      },
      {
        from_port           = 9100
        to_port             = 9100
        protocol            = "tcp"
        cidr_blocks         = null
        self                = true
        security_group_name = null
        description         = "Permite la comunicacion RCP interna entre los nodos"
      },
      {
        from_port           = 6379
        to_port             = 6379
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion con YEDIS"
      },
      {
        from_port           = 9042
        to_port             = 9042
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion con YCQL"
      },
      {
        from_port           = 5433
        to_port             = 5433
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion con YSQL"
      },
      {
        from_port           = 18018
        to_port             = 18018
        protocol            = "tcp"
        cidr_blocks         = null
        self                = true
        security_group_name = null
        description         = "Permite la comunicacion con YB Controller"
      },
      {
        from_port           = 9070
        to_port             = 9070
        protocol            = "tcp"
        cidr_blocks         = null
        self                = true
        security_group_name = null
        description         = "Permite la comunicacion con Node Agent"
      },
      {
        from_port           = 9090
        to_port             = 9090
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion con YB Controller"
      },
      {
        from_port           = 9300
        to_port             = 9300
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion con Node Agent"
      }
    ]
    egress = [
      {
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la salida hacia el Transit Gateway"
      }
    ]
  }

  webmethods-sg = {
    name        = "apolo-webmethods"
    description = "Security Group para WebMethods"
    ingress = [
      {
        from_port           = 80
        to_port             = 80
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite el acceso HTTP al servidor de WebMethods a traves del Transit Gateway."
      },
      {
        from_port           = 443
        to_port             = 443
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite el acceso HTTPS al servidor de WebMethods a traves del Transit Gateway."
      },
      {
        from_port           = 22
        to_port             = 22
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite el acceso SSH al servidor de WebMethods a traves del Transit Gateway."
      },
      {
        from_port           = 3389
        to_port             = 3389
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite el acceso RDP al servidor de WebMethods a traves del Transit Gateway."
      },
      {
        from_port           = 21
        to_port             = 21
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite el acceso FTP al servidor de WebMethods a traves del Transit Gateway."
      },
      {
        from_port           = 990
        to_port             = 990
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite el acceso FTPS al servidor de WebMethods a traves del Transit Gateway."
      },
      {
        from_port           = 110
        to_port             = 110
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la obtencion de email via POP3 a traves del Transit Gateway."
      },
      {
        from_port           = 995
        to_port             = 995
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la obtencion de email via POP3 SSL a traves del Transit Gateway."
      },
      {
        from_port           = 143
        to_port             = 143
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la obtencion de email via IMAP a traves del Transit Gateway."
      },
      {
        from_port           = 993
        to_port             = 993
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la obtencion de email via IMAP SSL a traves del Transit Gateway."
      },
      {
        from_port           = 5985
        to_port             = 5985
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite las conexiones WinRM-HTTP a traves del Transit Gateway."
      },
      {
        from_port           = 5986
        to_port             = 5986
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite las conexiones WinRM-HTTPS a traves del Transit Gateway."
      }
    ]
    egress = [
      {
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la salida hacia el Transit Gateway"
      }
    ]
  }

  rds-oracle-sg = {
    name        = "apolo-rds-oracle"
    description = "Security Group para RDS Oracle"
    ingress = [
      {
        from_port           = 1521
        to_port             = 1521
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite el acceso al servidor Oracle RDS a traves del Transit Gateway."
      }
    ]
    egress = [
      {
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la salida hacia el Transit Gateway"
      }
    ]
  }

  elc-redis-sg = {
    name        = "apolo-elc-redis"
    description = "Security Group para Redis"
    ingress = [
      {
        from_port           = 6379
        to_port             = 6379
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite el trafico de Redis a traves del Transit Gateway."
      },
      {
        from_port           = 6380
        to_port             = 6380
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite el trafico encriptado de Redis a traves del Transit Gateway."
      }
    ]
    egress = [{
      from_port           = 0
      to_port             = 0
      protocol            = "-1"
      cidr_blocks         = ["0.0.0.0/0"]
      self                = null
      security_group_name = null
      description         = "Permite la salida hacia el Transit Gateway"
    }]
  }
}

nat_gateway_subnets = [
]

nat_gateway_cidr_blocks = {
}

# Subntes que tendran trafico directamente al Transit Gateway
transit_gateway_cidr_blocks = {
  eks-control-plane-a = ["0.0.0.0/0"],
  eks-control-plane-b = ["0.0.0.0/0"],
  eks-control-plane-c = ["0.0.0.0/0"],
  nlb-nat-eks-a       = ["0.0.0.0/0"],
  nlb-nat-eks-b       = ["0.0.0.0/0"],
  nlb-nat-eks-c       = ["0.0.0.0/0"],
  yugabytedb-a        = ["0.0.0.0/0"],
  yugabytedb-b        = ["0.0.0.0/0"],
  yugabytedb-c        = ["0.0.0.0/0"],
  rds-oracle-a        = ["0.0.0.0/0"],
  rds-oracle-b        = ["0.0.0.0/0"],
  webmethods-a        = ["0.0.0.0/0"],
  webmethods-b        = ["0.0.0.0/0"],
  webmethods-c        = ["0.0.0.0/0"],
  elc-redis-a         = ["0.0.0.0/0"],
  elc-redis-b         = ["0.0.0.0/0"],
  elc-redis-c         = ["0.0.0.0/0"]
}

# Bancoppel Transit Gateway
transit_gateway_id = "tgw-0ab160e65d544e58b"


# Tablas de rutas extra

extra_route_tables = [
  "eks-node-a",
  "eks-node-b",
  "eks-node-c"
]