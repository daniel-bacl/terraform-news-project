resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.eks_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  enabled_cluster_log_types = ["api", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  remote_access {
    ec2_ssh_key = "my-kp"
  }

  tags = {
    Name = "${var.cluster_name}-ng"
  }
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0c0e66e9a"]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}