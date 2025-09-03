output "vpc_id" {
  value = aws_vpc.this.id
}
output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}
output "app_subnet_ids" {
  value = [for s in aws_subnet.app : s.id]
}
output "db_subnet_ids" {
  value = [for s in aws_subnet.db : s.id]
}

output "eks_private_subnets" {
  value = aws_subnet.eks_private[*].id
}

output "eks_public_subnets" {
  value = aws_subnet.eks_public[*].id
}
