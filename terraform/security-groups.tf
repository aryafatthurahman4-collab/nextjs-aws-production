# Security Group for EC2
resource "aws_security_group" "ec2" {
  name_prefix = "${var.project_name}-ec2-"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# SSH access (dibatasi ke IP admin)
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.ec2.id
  description       = "SSH from admin IP"
  cidr_ipv4         = var.ssh_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# HTTP access
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.ec2.id
  description       = "HTTP access"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# HTTPS access
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.ec2.id
  description       = "HTTPS access"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# All outbound traffic
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.ec2.id
  description       = "All outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  count       = var.enable_rds ? 1 : 0
  name_prefix = "${var.project_name}-rds-"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-rds-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# RDS ingress from EC2
resource "aws_vpc_security_group_ingress_rule" "rds_from_ec2" {
  count                        = var.enable_rds ? 1 : 0
  security_group_id            = aws_security_group.rds[0].id
  description                  = "PostgreSQL from EC2"
  referenced_security_group_id = aws_security_group.ec2.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

# RDS egress
resource "aws_vpc_security_group_egress_rule" "rds_all" {
  count             = var.enable_rds ? 1 : 0
  security_group_id = aws_security_group.rds[0].id
  description       = "All outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
