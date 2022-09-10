resource "aws_iam_role" "whyxn-eks" {
  name = "eks-cluster-whyxn"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "whyxn-eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.whyxn-eks.name
}

resource "aws_eks_cluster" "whyxn-eks" {
  name      = "whyxn-eks"
  role_arn  = aws_iam_role.whyxn-eks.arn
  version   = "1.22"

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids = [
      aws_subnet.private-ap-southeast-1a.id,
      aws_subnet.private-ap-southeast-1b.id,
      aws_subnet.public-ap-southeast-1a.id,
      aws_subnet.public-ap-southeast-1b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.whyxn-eks-AmazonEKSClusterPolicy]
}