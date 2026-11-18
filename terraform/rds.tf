# RDS PostgreSQL Configuration
resource "aws_db_subnet_group" "main" {
  count      = var.enable_rds ? 1 : 0
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  count = var.enable_rds ? 1 : 0

  identifier     = "${var.project_name}-postgres"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = var.rds_instance_class

  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.rds_database_name
  username = var.rds_master_username
  password = var.rds_master_password

  db_subnet_group_name   = aws_db_subnet_group.main[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]
  publicly_accessible    = false
  multi_az               = var.rds_multi_az

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  enabled_cloudwatch_logs_exports = ["postgresql"]
  performance_insights_enabled    = true

  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.project_name}-final-snapshot"

  tags = {
    Name = "${var.project_name}-postgres"
  }
}
