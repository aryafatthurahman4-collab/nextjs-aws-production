# Terraform Variables
# Update these values with your actual AWS credentials and configuration

# AWS Configuration
aws_region   = "ap-southeast-1"
project_name = "nextjs-aws-production"
environment  = "prod"

# EC2 Configuration
instance_type  = "t3.micro"
key_name       = "" # Leave empty to create new key pair
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINOR/OlgXYUhIMQoHyKp3+LRUqUxJVh/vjRDCIYP9klk aryaf@windows"
# SSH dibatasi ke IP publik kamu (180.247.57.13 saat ini).
ssh_cidr = "180.247.57.13/32"

# Domain Configuration
domain_name = ""
email       = ""

# VPC Configuration
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

# RDS Configuration (dimatikan: PostgreSQL jalan sebagai container di EC2)
enable_rds            = false
rds_instance_class    = "db.t3.micro"
rds_allocated_storage = 20
rds_database_name     = "appdb"
rds_master_username   = "appuser"
rds_master_password   = ""
rds_multi_az          = false
enable_nat_gateway    = false # Set to true if you need NAT for private subnets
