resource "aws_security_group" "eks" {
  name        = "${var.cluster_name}-sg"
  description = "EKS security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
