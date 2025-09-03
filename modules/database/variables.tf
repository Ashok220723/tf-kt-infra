variable "vpc_id" {}
variable "db_subnet_ids" { type = list(string) }
variable "app_sg_id" {}
variable "db_sg_id" {}
variable "engine_version" { type = string }
variable "instance_class" { type = string }
variable "multi_az" { type = bool }
variable "allocated_storage" { type = number }
