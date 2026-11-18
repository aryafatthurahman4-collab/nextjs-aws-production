output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "Elastic IP address"
  value       = aws_eip.app.public_ip
}

output "public_dns" {
  description = "Public DNS name"
  value       = aws_instance.app.public_dns
}

output "app_url" {
  description = "Application URL"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "http://${aws_eip.app.public_ip}"
}

output "health_url" {
  description = "Health check URL"
  value       = var.domain_name != "" ? "https://${var.domain_name}/api/health" : "http://${aws_eip.app.public_ip}/api/health"
}

output "ssh_command" {
  description = "SSH command to connect to instance"
  value       = "ssh -i <path-to-key.pem> ubuntu@${aws_eip.app.public_ip}"
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "security_group_id" {
  description = "EC2 security group ID"
  value       = aws_security_group.ec2.id
}

# RDS outputs
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = var.enable_rds ? aws_db_instance.main[0].endpoint : "RDS not enabled"
}

output "rds_database_name" {
  description = "RDS database name"
  value       = var.enable_rds ? aws_db_instance.main[0].db_name : "RDS not enabled"
}

output "rds_master_username" {
  description = "RDS master username"
  value       = var.enable_rds ? aws_db_instance.main[0].username : "RDS not enabled"
  sensitive   = true
}

output "rds_connection_string" {
  description = "RDS connection string"
  value       = var.enable_rds ? "postgresql://${aws_db_instance.main[0].username}:${var.rds_master_password}@${aws_db_instance.main[0].endpoint}/${aws_db_instance.main[0].db_name}" : "RDS not enabled"
  sensitive   = true
}
