# Private Hosted Zone
resource "aws_route53_zone" "private" {
  name = "internal.${var.app_name}.com"

  vpc {
    vpc_id = aws_vpc.main.id
  }

  tags = {
    Name        = "${var.app_name}-private-zone"
    Environment = var.environment
  }
}

# DNS Records
resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "app.internal.${var.app_name}.com"
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "db.internal.${var.app_name}.com"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.main.address]
}
