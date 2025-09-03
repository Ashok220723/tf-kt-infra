project     = "kt"
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


# EKS private subnets for nodes
eks_private_subnet_cidrs = ["10.0.80.0/20", "10.0.96.0/20"]

# EKS public subnets for ALBs
eks_public_subnet_cidrs  = ["10.0.120.0/24", "10.0.121.0/24"]

cluster_name = "dev-kt-eks"
desired_size   = 2
min_size       = 1
max_size       = 3
instance_types = ["t3.medium"]
eks_version    = "1.31"



app_desired       = 2
app_min           = 2
app_max           = 4
app_instance_type = "t3.micro"

rds_engine_version   = "8.0"
rds_instance_class   = "db.t3.micro"
rds_multi_az         = false
rds_allocated_storage = 20

extra_tags = {
  Owner = "kt-platform-team"
  Stage = "dev"
}
