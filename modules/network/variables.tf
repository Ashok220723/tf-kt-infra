variable "project" {}
variable "environment" {}
variable "vpc_cidr" {}
variable "azs" { type = list(string) }
variable "public_subnet_cidrs" { type = list(string) }
variable "app_subnet_cidrs" { type = list(string) }
variable "db_subnet_cidrs" { type = list(string) }
variable "nat_mode" { type = string }
variable "enable_flow_logs" { type = bool }
variable "enable_ssm_endpoints" { type = bool }
