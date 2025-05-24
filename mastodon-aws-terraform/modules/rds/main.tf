resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name    = "${var.project_name}-db-subnet"
    Project = var.project_name
  }
}

resource "aws_db_instance" "mastodon" {
  identifier = "${var.project_name}-db"
  engine     = "postgres"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  username = var.db_username
  password = var.db_password
  db_name  = "mastodon"
  multi_az = true
  backup_retention_period = 7
  vpc_security_group_ids = [var.sg_id]
  db_subnet_group_name = aws_db_subnet_group.main.name
  skip_final_snapshot = true
  tags = {
    Name    = "${var.project_name}-db"
    Project = var.project_name
  }
}

output "rds_endpoint" {
  value       = aws_db_instance.mastodon.endpoint
  description = "Endpoint de PostgreSQL RDS usado por Mastodon"
}

output "db_instance_id" {
  description = "El ID de la instancia RDS"
  value       = aws_db_instance.mastodon.id
}