#### IAM Roles ####

# IAM Role for Cluster Autoscaler
resource "aws_iam_role" "role-ekssa-cluster-autoscaler" {
  assume_role_policy = data.aws_iam_policy_document.policy-ekssa-cluster-autoscaler.json
  name               = var.name-role-ekssa-cluster-autoscaler 
}

data "aws_iam_policy_document" "policy-ekssa-cluster-autoscaler" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role_policy_attachment" "role-ekssa-cluster-autoscaler-policya-1" {
  role       = aws_iam_role.role-ekssa-cluster-autoscaler.name
  policy_arn = aws_iam_policy.policy-ekssa-cluster-autoscaler.arn
}

resource "aws_iam_policy" "policy-ekssa-cluster-autoscaler" {
  name        = "policy-${var.name-role-ekssa-cluster-autoscaler}"
  path        = "/"
  description = "Policy for Cluster Autoscaler IAM Role"
  policy = file("${path.module}/json/cluster-autoscaler-policy.json")
}