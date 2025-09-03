resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project}-${var.environment}-eks-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.eks_private_subnet_ids

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  instance_types = var.instance_types

  tags = {
    Name = "${var.project}-${var.environment}-eks-nodes"
    # Required so EC2 instances get tagged properly
    "kubernetes.io/cluster/${aws_eks_cluster.this.name}" = "owned"
  }
}
