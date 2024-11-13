output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "web_alb_dns" {
  description = "DNS name of the web tier load balancer"
  value       = aws_lb.web.dns_name
}

output "app_internal_dns" {
  description = "Internal DNS name for the application tier"
  value       = aws_route53_record.app.name
}

output "db_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.main.endpoint
}

output "private_zone_id" {
  description = "Route53 private hosted zone ID"
  value       = aws_route53_zone.private.zone_id
}
