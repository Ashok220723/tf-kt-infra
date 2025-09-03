resource "aws_eks_cluster" "this" {
  name     = "${var.project}-${var.environment}-eks"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = var.eks_private_subnet_ids
  }

  tags = {
    Name = "${var.project}-${var.environment}-eks"
  }
}
