# Salida que muestra la región en donde se realizaron las pruebas
output "aws_region" {
  description = "Región en la cual se han realizado las pruebas"
  value       = var.region
}

# Salida que muestra los identificadores las rutas de las tablas de ruteo las subnets creadas con ruta al Transit Gateway
output "expected_route_tables_transit_subnets" {
  description = "Tablas de ruteo de las subnets que deben tener rutas al Transit Gateway"
  value = [
    for table in aws_route_table.private_route_table :
    table.id
  ]
}