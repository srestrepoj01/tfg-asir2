variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "ec2_instance_ids" {
  description = "Lista de IDs de instancias EC2 para monitorear"
  type        = list(string)
}

variable "rds_instance_id" {
  description = "ID de la instancia RDS para monitorear"
  type        = string
}

variable "lb_arn_suffix" {
  description = "Sufijo ARN del balanceador de carga"
  type        = string
}

variable "target_group_web_arn_suffix" {
  description = "Sufijo ARN del grupo objetivo web"
  type        = string
}

variable "target_group_streaming_arn_suffix" {
  description = "Sufijo ARN del grupo objetivo de streaming"
  type        = string
}

variable "alarm_email" {
  description = "Direccion de correo electronico para enviar notificaciones de alarmas"
  type        = string
}