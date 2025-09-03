project     = "dev-vpc-01"
environment = "dev"
aws_region  = "ap-south-1"

vpc_cidr = "10.0.0.0/16"
azs      = ["ap-south-1a", "ap-south-1b"]

# Web/public /24s
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]

# App/private /20s
app_subnet_cidrs = ["10.0.16.0/20", "10.0.32.0/20"]

# DB/private /20s
db_subnet_cidrs = ["10.0.48.0/20", "10.0.64.0/20"]

nat_mode = "per_az"

app_desired       = 2
app_min           = 2
app_max           = 4
app_instance_type = "t3.micro"

rds_engine_version   = "8.0"
rds_instance_class   = "db.t3.micro"
rds_multi_az         = false
rds_allocated_storage = 20

extra_tags = {
  Owner = "platform-team"
  Stage = "dev"
}
