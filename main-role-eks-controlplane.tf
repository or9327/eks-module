#### IAM Role ####

# IAM Role for EKS Cluster Control Plane (= Cluster IAM Role)
resource "aws_iam_role" "role-eks-controlplane" {
  name = var.name-role-eks-controlplane
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role-eks-controlplane-policya-1" {
  role       = aws_iam_role.role-eks-controlplane.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

   # Security Groups for Pods 기능 사용을 위한 설정
   # https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "role-eks-controlplane-policya-2" {
  role       = aws_iam_role.role-eks-controlplane.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}
