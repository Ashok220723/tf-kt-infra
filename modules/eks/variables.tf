
variable "project" {
  type        = string
  description = "Project name used for tagging and naming resources"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the EKS cluster will be deployed"
}


variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}


variable "eks_private_subnet_ids" {
  type        = list(string)
  description = "Private subnets for EKS worker nodes"
}

variable "eks_public_subnet_ids" {
  type        = list(string)
  description = "Public subnets for EKS load balancers"
}

variable "desired_size" {
  type        = number
  description = "Desired number of worker nodes"
}

variable "min_size" {
  type        = number
  description = "Minimum number of worker nodes"
}

variable "max_size" {
  type        = number
  description = "Maximum number of worker nodes"
}

variable "instance_types" {
  type        = list(string)
  description = "Instance types for the worker nodes"
}

variable "eks_version" {
  type        = string
  description = "EKS cluster version"
}
