variable "vpc_id" {
  type        = string
  description = "ID de la VPC para el ALB y grupos objetivo"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "IDs de subredes publicas para el ALB"
}

variable "sg_id" {
  type        = string
  description = "Grupo de seguridad para el ALB"
}

variable "project_name" {
  type        = string
  description = "Prefijo usado para nombrar y etiquetar recursos"
}

variable "ec2_instance_ids" {
  description = "Lista de IDs de instancias EC2 para registrar en los grupos objetivo del ALB"
  type        = list(string)
}