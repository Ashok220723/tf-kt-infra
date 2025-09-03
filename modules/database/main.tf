resource "random_password" "master" {
  length           = 20
  special          = true
  override_characters = "!@#_-=+"
}

resource "aws_db_subnet_group" "this" {
  name       = "db-subnets"
  subnet_ids = var.db_subnet_ids
}

resource "aws_kms_key" "rds" {
  description         = "KMS key for RDS"
  enable_key_rotation = true
}

resource "aws_db_parameter_group" "mysql" {
  name        = "mysql-params"
  family      = "mysql${replace(var.engine_version, ".", "")}"
  description = "Param group"
}

resource "aws_db_instance" "this" {
  identifier              = "mysql-${var.multi_az ? "multi" : "single"}"
  engine                  = "mysql"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.db_sg_id]
  allocated_storage       = var.allocated_storage
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.rds.arn
  username                = "admin"
  password                = random_password.master.result
  skip_final_snapshot     = true
  multi_az                = var.multi_az
  apply_immediately       = true
  publicly_accessible     = false
  deletion_protection     = false
  parameter_group_name    = aws_db_parameter_group.mysql.name
}

output "rds_endpoint"    { value = aws_db_instance.this.address }
output "rds_master_user" { value = aws_db_instance.this.username }
output "rds_master_pass" {
  value     = random_password.master.result
  sensitive = true
}
