#### EKS Control Plane ####

resource "aws_eks_cluster" "eks" {
  name     = var.name-cluster # 반드시 소문자여야 함 
  version  = var.control-plane-k8s-version
  role_arn = aws_iam_role.role-eks-controlplane.arn

  vpc_config {
    subnet_ids = [var.id-subnet-1, var.id-subnet-2]
    endpoint_private_access = true
    endpoint_public_access = var.allow-endpoint-public-access
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.service-ipv4-cidr
  }

  enabled_cluster_log_types = ["api", "audit"]

  # EKS Cluster 용 Role의 Permission 할당과 생성/삭제에 대한 종속성 있음 (반드시 적용 필요!!)
  depends_on = [
    aws_iam_role_policy_attachment.role-eks-controlplane-policya-1,
    aws_iam_role_policy_attachment.role-eks-controlplane-policya-2
  ]

  tags = var.tags-control-plane
}

output "cluster-endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster-ca-data" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}

output "id-cluster-security-group" {
  value = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

#### OIDC Provider ####

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks-certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

data "tls_certificate" "eks-certificate" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

#### EKS Add-On ####

resource "aws_eks_addon" "eks-addon-vpc-cni" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "vpc-cni"
  addon_version            = var.version-vpc-cni-addon
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = aws_iam_role.role-ekssa-aws-node.arn
}

resource "aws_eks_addon" "eks-addon-kube-proxy" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "kube-proxy"
  addon_version            = var.version-kube-proxy-addon
  resolve_conflicts        = "OVERWRITE"
}