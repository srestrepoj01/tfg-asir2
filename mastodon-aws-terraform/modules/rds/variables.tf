variable "project_name" {
  type        = string
  description = "Prefijo usado para nombrar recursos EC2"
}

variable "vpc_id" {
  type        = string
  description = "ID de la VPC donde se lanzaran las instancias"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "IDs de subredes privadas para RDS"
}

variable "sg_id" {
  type        = string
  description = "ID del grupo de seguridad para asignar a las EC2"
}

variable "db_username" {
  description = "Nombre de usuario de la base de datos RDS"
  type        = string
}

variable "db_password" {
  description = "Contrasena de la base de datos RDS"
  type        = string
  sensitive   = true
}
