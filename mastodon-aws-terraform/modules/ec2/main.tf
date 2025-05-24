resource "aws_instance" "mastodon" {
  count = var.instance_count

  ami                         = "ami-0ff71843f814379b3"  # Ubuntu 22.04 en eu-west-3
  instance_type               = var.instance_type
  subnet_id                   = element(var.public_subnet_ids, count.index)
  associate_public_ip_address = true
  key_name                    = var.ssh_key_name
  #security_groups             = [var.sg_id]
  vpc_security_group_ids      = [var.sg_id]
  iam_instance_profile        = var.iam_instance_profile
  
  root_block_device {
    volume_size           = var.ec2_root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # user_data solo para la configuracion inicial de docker
  user_data = file("${path.module}/../../user_data/install_docker.sh")

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }

  tags = {
    Name    = "${var.project_name}-ec2-${count.index}"
    Project = var.project_name
  }
}

resource "null_resource" "mastodon_provisioner" {
  count = var.instance_count

  triggers = {
    instance_id = aws_instance.mastodon[count.index].id
    script_hash = filesha256("${path.module}/../../user_data/mastodon-deploy.sh")
  }

  provisioner "file" {
    source      = "${path.module}/../../user_data/mastodon-deploy.sh"
    destination = "/home/ubuntu/mastodon-deploy.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = aws_instance.mastodon[count.index].public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      # Verificar si los contenedores de Mastodon estan corriendo por nombre de contenedor que empieza con 'mastodon-'
      "if docker ps --format '{{.Names}}' | grep -q '^mastodon-'; then",
      "  echo 'Mastodon is already running, skipping provisioning.'",
      "  exit 0",
      "fi",
      # Si no estan corriendo, continuar con el despliegue
      "chmod +x /home/ubuntu/mastodon-deploy.sh",
      "sudo bash /home/ubuntu/mastodon-deploy.sh",
      "echo 'Mastodon provisioning completed successfully'"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = aws_instance.mastodon[count.index].public_ip
    }
  }

  depends_on = [aws_instance.mastodon]
}

resource "aws_eip" "mastodon" {
  count      = var.instance_count
  instance   = aws_instance.mastodon[count.index].id
  domain     = "vpc"


  tags = {
    Name    = "${var.project_name}-eip-${count.index}"
    Project = var.project_name
  }
}


output "instance_ids" {
  value       = aws_instance.mastodon[*].id
  description = "List of EC2 instance IDs"
}

output "public_ips" {
  value       = aws_instance.mastodon[*].public_ip
  description = "Public IPs of the EC2 instances"
}
