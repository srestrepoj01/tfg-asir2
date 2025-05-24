output "dns_name" {
  value       = aws_lb.mastodon.dns_name
  description = "Nombre DNS del ALB"
}