output "elastic_ips" {
  description = "IPs elasticas asignadas a cada instancia EC2"
  value       = aws_eip.mastodon[*].public_ip
}
