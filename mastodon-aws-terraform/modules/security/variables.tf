variable "vpc_id" {
  description = "ID de la VPC donde se crearan los grupos de seguridad"
  type        = string
}

variable "project_name" {
  description = "Prefijo para nombrar los grupos de seguridad"
  type        = string
}
