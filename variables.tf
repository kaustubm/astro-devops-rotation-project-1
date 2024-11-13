variable "environment" {
  description = "Environment name"
  default     = "prod"
}

variable "app_name" {
  description = "Application name"
  default     = "three-tier-app"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.16.0.0/16" # Allows for up to 65,536 IP addresses
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (web tier)"
  type        = list(string)
  default = [
    "10.16.0.0/24", # 256 IPs for public subnet in AZ1
    "10.16.1.0/24"  # 256 IPs for public subnet in AZ2
  ]
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for application tier private subnets"
  type        = list(string)
  default = [
    "10.16.10.0/23", # 512 IPs for app subnet in AZ1
    "10.16.12.0/23"  # 512 IPs for app subnet in AZ2
  ]
}

variable "db_subnet_cidrs" {
  description = "CIDR blocks for database tier private subnets"
  type        = list(string)
  default = [
    "10.16.20.0/24", # 256 IPs for db subnet in AZ1
    "10.16.21.0/24"  # 256 IPs for db subnet in AZ2
  ]
}

variable "availability_zones" {
  description = "AZs in Singapore region"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}
