module "network" {
  source = "./modules/network"

  project              = var.project
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  app_subnet_cidrs     = var.app_subnet_cidrs
  db_subnet_cidrs      = var.db_subnet_cidrs
  eks_private_subnet_cidrs = var.eks_private_subnet_cidrs
  eks_public_subnet_cidrs  = var.eks_public_subnet_cidrs
  nat_mode             = var.nat_mode
  enable_flow_logs     = var.enable_flow_logs
  enable_ssm_endpoints = var.enable_ssm_endpoints
}



locals {
  cluster_name = "${var.project}-${var.environment}-eks"
}

module "eks" {
  source = "./modules/eks"

  project                = var.project
  environment            = var.environment
  cluster_name           = local.cluster_name
  vpc_id = module.network.vpc_id 
  eks_private_subnet_ids = module.network.eks_private_subnets
  eks_public_subnet_ids  = module.network.eks_public_subnets

  desired_size   = var.desired_size
  min_size       = var.min_size
  max_size       = var.max_size
  instance_types = var.instance_types
  eks_version    = var.eks_version
}


# module "security" {
#   source = "./modules/security"

#   vpc_id         = module.network.vpc_id
#   alb_subnet_ids = module.network.public_subnet_ids
#   app_subnet_ids = module.network.app_subnet_ids
#   db_subnet_ids  = module.network.db_subnet_ids
# }

# module "webapp" {
#   source = "./modules/webapp"

#   vpc_id         = module.network.vpc_id
#   alb_subnet_ids = module.network.public_subnet_ids
#   app_subnet_ids = module.network.app_subnet_ids
#   alb_sg_id      = module.security.alb_sg_id
#   app_sg_id      = module.security.app_sg_id

#   desired_capacity = var.app_desired
#   min_size         = var.app_min
#   max_size         = var.app_max
#   instance_type    = var.app_instance_type
#   keypair_name     = var.keypair_name
# }

# module "database" {
#   source = "./modules/database"

#   vpc_id            = module.network.vpc_id
#   db_subnet_ids     = module.network.db_subnet_ids
#   app_sg_id         = module.security.app_sg_id
#   db_sg_id          = module.security.db_sg_id
#   engine_version    = var.rds_engine_version
#   instance_class    = var.rds_instance_class
#   multi_az          = var.rds_multi_az
#   allocated_storage = var.rds_allocated_storage
# }


