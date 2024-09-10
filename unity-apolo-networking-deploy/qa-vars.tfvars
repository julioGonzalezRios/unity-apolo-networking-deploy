region = "us-east-1"

vpc = {
  cidr_block = "10.209.28.0/23"
  name       = "ApoloNonProdQA"
}

vpc_cidr_blocks = ["100.64.0.0/16"]

environment = "qa"

tags = {
  "Application Role" = "networking",
  "Project"          = "Unity",
  "Owner"            = "Caroline-Su",
  "Cost Center"      = "232020 MHGO NVO CORE",
  "Business Unit"    = "Apolo",
  "Version"          = "1.0"
}

subnets = {
  eks-control-plane-a = {
    availability_zone                 = "us-east-1a"
    cidr_block                        = "10.209.28.0/27"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  eks-control-plane-b = {
    availability_zone                 = "us-east-1b"
    cidr_block                        = "10.209.28.32/27"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  eks-control-plane-c = {
    availability_zone                 = "us-east-1c"
    cidr_block                        = "10.209.28.64/27"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  yugabytedb-a = {
    availability_zone                 = "us-east-1a"
    cidr_block                        = "10.209.28.224/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  yugabytedb-b = {
    availability_zone                 = "us-east-1b"
    cidr_block                        = "10.209.28.240/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  yugabytedb-c = {
    availability_zone                 = "us-east-1c"
    cidr_block                        = "10.209.29.0/28"
    transit_gateway_direct_connection = true
    nat_gateway_name                  = null
  }

  keycloak-a = {
    availability_zone                 = "us-east-1a"
    cidr_block                        = "10.209.29.16/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  keycloak-b = {
    availability_zone                 = "us-east-1b"
    cidr_block                        = "10.209.29.32/28"
    transit_gateway_direct_connection = true
    nat_gateway_name                  = null
  }

  eks-node-a = {
    availability_zone                 = "us-east-1a"
    cidr_block                        = "100.64.64.0/18"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }


  eks-node-b = {
    availability_zone                 = "us-east-1b"
    cidr_block                        = "100.64.0.0/18"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  eks-node-c = {
    availability_zone                 = "us-east-1c"
    cidr_block                        = "100.64.128.0/18"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  alb-yugabytedb-a = {
    availability_zone                 = "us-east-1a"
    cidr_block                        = "10.209.29.48/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  alb-yugabytedb-b = {
    availability_zone                 = "us-east-1b"
    cidr_block                        = "10.209.29.64/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  alb-yugabytedb-c = {
    availability_zone                 = "us-east-1c"
    cidr_block                        = "10.209.29.80/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }
  alb-nat-eks-a = {
    availability_zone                 = "us-east-1a"
    cidr_block                        = "10.209.29.96/28"
    transit_gateway_direct_connection = true
    nat_gateway_name                  = null
  }

  alb-eks-b = {
    availability_zone                 = "us-east-1b"
    cidr_block                        = "10.209.29.112/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  alb-eks-c = {
    availability_zone                 = "us-east-1c"
    cidr_block                        = "10.209.29.128/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  alb-keycloak-a = {
    availability_zone                 = "us-east-1a"
    cidr_block                        = "10.209.29.144/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }

  alb-keycloak-b = {
    availability_zone                 = "us-east-1b"
    cidr_block                        = "10.209.29.160/28"
    transit_gateway_direct_connection = false
    nat_gateway_name                  = null
  }
}

security_groups = {
  keycloak-sg = {
    name        = "apolo-keycloak"
    description = "Security Group para KEYCLOAK"
    ingress = [
      {
        from_port           = 80
        to_port             = 80
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion HTTP con KEYCLOAK."
      },
      {
        from_port           = 443
        to_port             = 443
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion desde el Transit Gateway"
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
}

nat_gateway_subnets = []

nat_gateway_cidr_blocks = {}
# Bancoppel Transit Gateway
transit_gateway_id = "tgw-012129fadcd7eeda8"

transit_gateway_cidr_blocks = {
  eks-control-plane-a = ["0.0.0.0/0"],
  eks-control-plane-b = ["0.0.0.0/0"],
  eks-control-plane-c = ["0.0.0.0/0"],
  alb-keycloak-a      = ["0.0.0.0/0"],
  alb-keycloak-b      = ["0.0.0.0/0"],
  keycloak-a          = ["0.0.0.0/0"],
  keycloak-b          = ["0.0.0.0/0"],
  alb-nat-eks-a       = ["0.0.0.0/0"],
  alb-eks-b           = ["0.0.0.0/0"],
  alb-eks-c           = ["0.0.0.0/0"],
  alb-yugabytedb-a    = ["0.0.0.0/0"],
  alb-yugabytedb-b    = ["0.0.0.0/0"],
  alb-yugabytedb-c    = ["0.0.0.0/0"],
  yugabytedb-a        = ["0.0.0.0/0"],
  yugabytedb-b        = ["0.0.0.0/0"],
  yugabytedb-c        = ["0.0.0.0/0"]
}