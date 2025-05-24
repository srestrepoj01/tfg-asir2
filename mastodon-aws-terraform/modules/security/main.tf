# Grupo de seguridad EC2 – permite que ALB acceda a los puertos 80 y 443, y SSH desde cualquier lugar (limita esto a tu IP en produccion)
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2"
  description = "Permitir acceso de ALB a EC2 y acceso SSH"
  vpc_id      = var.vpc_id

  ingress {
    description = "Acceso SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Reemplaza con tu rango de IP en produccion - SE CAMBIA LUEGO A "MY IP"
  }

  ingress {
    description = "HTTP desde ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS desde ALB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Servicio web (puerto 3000) desde ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Servicio de streaming (puerto 4000) desde ALB"
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-ec2-sg"
    Project = var.project_name
  }
}

# Grupo de seguridad ALB – permite a usuarios de internet acceder a los puertos 80 y 443
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb"
  description = "Permitir acceso publico HTTP y HTTPS"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP desde internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS desde internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-alb-sg"
    Project = var.project_name
  }
}

# Grupo de seguridad RDS – permite a EC2 acceder a PostgreSQL
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds"
  description = "Permitir a EC2 acceder a PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL desde EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-rds-sg"
    Project = var.project_name
  }
}

output "ec2_sg_id" {
  value = aws_security_group.ec2.id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}