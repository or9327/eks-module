#### IAM Role ####

# IAM Role for AWS Load Balancer Controller
resource "aws_iam_role" "role-ekssa-aws-load-balancer-controller" {
  assume_role_policy = data.aws_iam_policy_document.policy-ekssa-aws-load-balancer-controller.json
  name               = var.name-role-ekssa-aws-load-balancer-controller
}

data "aws_iam_policy_document" "policy-ekssa-aws-load-balancer-controller" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role_policy_attachment" "role-ekssa-aws-load-balancer-controller-policya-1" {
  role       = aws_iam_role.role-ekssa-aws-load-balancer-controller.name
  policy_arn = aws_iam_policy.policy-ekssa-aws-load-balancer-controller.arn
}

resource "aws_iam_policy" "policy-ekssa-aws-load-balancer-controller" {
  name        = "policy-${var.name-role-ekssa-aws-load-balancer-controller}"
  path        = "/"
  description = "Policy for AWS Load Balancer Controller IAM Role"
  policy = file("${path.module}/json/lb-controller-policy.json")
}