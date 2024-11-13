# Web Tier Security Group
resource "aws_security_group" "web" {
  name        = "${var.app_name}-web-sg"
  description = "Security group for web tier"
  vpc_id      = aws_vpc.main.id

  # Allow HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS inbound"
  }

  # Allow HTTP from anywhere (consider removing in production)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP inbound"
  }

  # Allow outbound only to application tier
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.app_subnet_cidrs
    description = "Allow outbound to application tier"
  }

  # Allow outbound HTTPS for patches and updates
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound for updates"
  }

  tags = {
    Name        = "${var.app_name}-web-sg"
    Environment = var.environment
  }
}

# Application Tier Security Group
resource "aws_security_group" "app" {
  name        = "${var.app_name}-app-sg"
  description = "Security group for application tier"
  vpc_id      = aws_vpc.main.id

  # Allow inbound only from web tier
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.public_subnet_cidrs
    description = "Allow inbound from web tier"
  }

  # Allow outbound only to database tier
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.db_subnet_cidrs
    description = "Allow outbound to database tier"
  }

  # Allow outbound HTTPS for patches and updates
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound for updates"
  }

  tags = {
    Name        = "${var.app_name}-app-sg"
    Environment = var.environment
  }
}

# Database Tier Security Group
resource "aws_security_group" "db" {
  name        = "${var.app_name}-db-sg"
  description = "Security group for database tier"
  vpc_id      = aws_vpc.main.id

  # Allow inbound only from application tier
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.app_subnet_cidrs
    description = "Allow inbound from application tier"
  }

  # No direct outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.app_subnet_cidrs
    description = "Allow outbound only to application tier"
  }

  tags = {
    Name        = "${var.app_name}-db-sg"
    Environment = var.environment
  }
}

# Network ACLs
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name        = "${var.app_name}-public-nacl"
    Environment = var.environment
  }
}
