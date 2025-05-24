variable "project_name" {
  type        = string
  description = "Prefijo usado para nombrar recursos EC2"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Lista de IDs de subredes publicas"
}


variable "sg_id" {
  type        = string
  description = "ID del grupo de seguridad para asignar a las EC2"
}

variable "iam_instance_profile" {
  type        = string
  description = "Nombre del perfil IAM para la instancia"
}

variable "instance_type" {
  type        = string
  description = "Tipo de instancia EC2"
}

variable "instance_count" {
  type        = number
  description = "Numero de instancias EC2 para lanzar"
}

variable "vpc_id" {
  type        = string
  description = "ID de la VPC donde se lanzaran las instancias"
}

variable "ssh_key_name" {
  description = "Nombre del par de llaves EC2 para acceso SSH"
  type        = string
}

variable "ec2_root_volume_size" {
  description = "Tamano del volumen raiz en GB para las instancias EC2"
  type        = number
  default     = 30
}

variable "private_key_path" {
  description = "Ruta a la llave privada SSH para conexion via remote-exec"
  type        = string
}
