variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "nextjs-aws-production"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 access"
  type        = string
  default     = ""
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH (set to your public IP /32)"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = ""
}

variable "email" {
  description = "Email for Let's Encrypt notifications"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "enable_rds" {
  description = "Enable RDS PostgreSQL database"
  type        = bool
  default     = false
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_database_name" {
  description = "RDS database name"
  type        = string
  default     = "appdb"
}

variable "rds_master_username" {
  description = "RDS master username"
  type        = string
  default     = "appuser"
}

variable "rds_master_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = false
}
