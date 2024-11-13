# IAM Role for EC2 instances in Application Tier
resource "aws_iam_role" "app_role" {
  name = "${var.app_name}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-app-role"
    Environment = var.environment
  }
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.app_name}-app-profile"
  role = aws_iam_role.app_role.name

  tags = {
    Name        = "${var.app_name}-app-profile"
    Environment = var.environment
  }
}

# IAM Role Policies
resource "aws_iam_role_policy_attachment" "app_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ])

  role       = aws_iam_role.app_role.name
  policy_arn = each.value
}
