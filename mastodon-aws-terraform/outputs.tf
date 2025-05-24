output "ec2_ips" {
  description = "Direcciones IP publicas de las instancias EC2"
  value       = module.ec2.public_ips
}

output "ec2_elastic_ips" {
  value       = module.ec2.elastic_ips
  description = "IPs elasticas asignadas a las instancias EC2 de Mastodon"
}

output "rds_endpoint" {
  description = "Direccion del endpoint de la instancia RDS PostgreSQL"
  value       = module.rds.rds_endpoint
}

output "alb_dns_name" {
  value       = module.alb.dns_name
  description = "Nombre DNS del balanceador de carga de aplicaciones (ALB)"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Lista de IDs de subredes publicas del modulo VPC"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Lista de IDs de subredes privadas del modulo VPC"
}