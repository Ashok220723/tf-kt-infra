variable "vpc_id" {}
variable "alb_subnet_ids" { type = list(string) }
variable "app_subnet_ids" { type = list(string) }
variable "db_subnet_ids"  { type = list(string) }
