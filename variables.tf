variable "project" {
  type = string
}
variable "environment" {
  type = string
}
variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "vpc_cidr" {
  type = string
}
variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}
variable "app_subnet_cidrs" {
  type = list(string)
}
variable "db_subnet_cidrs" {
  type = list(string)
}

variable "nat_mode" {
  type    = string
  default = "per_az"
  validation {
    condition     = contains(["single", "per_az"], var.nat_mode)
    error_message = "nat_mode must be 'single' or 'per_az'"
  }
}

variable "keypair_name" {
  type    = string
  default = null
}
variable "enable_flow_logs" {
  type    = bool
  default = true
}
variable "enable_ssm_endpoints" {
  type    = bool
  default = true
}

variable "app_desired" {
  type    = number
  default = 2
}
variable "app_min" {
  type    = number
  default = 2
}
variable "app_max" {
  type    = number
  default = 4
}
variable "app_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "rds_engine_version" {
  type    = string
  default = "8.0"
}
variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "rds_multi_az" {
  type    = bool
  default = false
}
variable "rds_allocated_storage" {
  type    = number
  default = 20
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}
