### DEFINE ROLE FOR EKS ###
resource "aws_iam_role" "eks" {
  name = "role-${var.cluster_name}"

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


### ATTACH POLICY TO ROLE ###
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}


### DEFINE EKS CLUSTER CONFIG ###
resource "aws_eks_cluster" "eks" {
  name      = var.cluster_name
  role_arn  = aws_iam_role.eks.arn
  version   = var.k8s_version

  vpc_config {
    endpoint_private_access = var.cluster_endpoint_is_private
    endpoint_public_access  = var.cluster_endpoint_is_public
    
    subnet_ids = [
      aws_subnet.private-a.id,
      aws_subnet.private-b.id,
      aws_subnet.public-a.id,
      aws_subnet.public-b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy]
}