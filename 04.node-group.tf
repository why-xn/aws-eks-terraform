resource "aws_iam_role" "whyxn-eks-nodes" {
  name = "eks-node-group-whyxn"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "whyxn-eks-nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.whyxn-eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "whyxn-eks-nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.whyxn-eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "whyxn-eks-nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.whyxn-eks-nodes.name
}

resource "aws_eks_node_group" "private-whyxn-eks-nodes-01" {
  cluster_name    = aws_eks_cluster.whyxn-eks.name
  node_group_name = "private-whyxn-eks-nodes-01"
  node_role_arn   = aws_iam_role.whyxn-eks-nodes.arn

  subnet_ids = [
    aws_subnet.private-ap-southeast-1a.id,
    aws_subnet.private-ap-southeast-1b.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "common"
  }

  depends_on = [
    aws_iam_role_policy_attachment.whyxn-eks-nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.whyxn-eks-nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.whyxn-eks-nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}