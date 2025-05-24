variable "project_name" {
  description = "Prefijo usado para nombrar recursos de AWS y etiquetarlos"
  type        = string
}

variable "region" {
  description = "Region de AWS donde se desplegaran los recursos"
  default     = "eu-west-3"
}

variable "ssh_key_name" {
  description = "Nombre del par de claves SSH - EC2"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "Lista de bloques CIDR permitidos para acceder por SSH a las instancias EC2"
  type        = list(string)
}

variable "db_username" {
  description = "Nombre de usuario maestro de PostgreSQL RDS"
  type        = string
}

variable "db_password" {
  description = "Contrasena maestra de PostgreSQL RDS"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  default     = "t2.medium"
}

variable "instance_count" {
  description = "Numero de instancias EC2 a lanzar"
  default     = 2
}

variable "private_key_path" {
  description = "Ruta a la clave SSH privada"
  type        = string
}

variable "alarm_email" {
  description = "Direccion de correo para enviar notificaciones de alarmas de CloudWatch"
  type        = string
}