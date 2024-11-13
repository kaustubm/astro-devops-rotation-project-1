# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = aws_subnet.private_db[*].id

  tags = {
    Name        = "${var.app_name}-db-subnet-group"
    Environment = var.environment
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier                = "${var.app_name}-db"
  allocated_storage         = 20
  storage_type              = "gp3"
  engine                    = "mysql"
  engine_version            = "8.0"
  instance_class            = "db.t3.micro"
  db_name                   = "appdb"
  username                  = var.db_username
  password                  = var.db_password
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.app_name}-db-final-snapshot"

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  multi_az          = true
  storage_encrypted = true

  tags = {
    Name        = "${var.app_name}-db"
    Environment = var.environment
  }
}
