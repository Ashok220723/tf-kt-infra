project     = "prod-vpc-01"
environment = "prod"
aws_region  = "ap-south-1"

vpc_cidr = "10.1.0.0/16"
azs      = ["ap-south-1a", "ap-south-1b"]

# Web/public /24s
public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]

# App/private /20s
app_subnet_cidrs = ["10.1.16.0/20", "10.1.32.0/20"]

# DB/private /20s
db_subnet_cidrs = ["10.1.48.0/20", "10.1.64.0/20"]

nat_mode = "per_az"

app_desired       = 4
app_min           = 3
app_max           = 6
app_instance_type = "t3.medium"

rds_engine_version   = "8.0"
rds_instance_class   = "db.t3.medium"
rds_multi_az         = true
rds_allocated_storage = 100

extra_tags = {
  Owner = "platform-team"
  Stage = "prod"
  Criticality = "high"
}
