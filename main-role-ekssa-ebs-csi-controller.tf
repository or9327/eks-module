#### IAM Role ####

# IAM Role for EBS CSI Controller
resource "aws_iam_role" "role-ekssa-ebs-csi-controller" {
  assume_role_policy = data.aws_iam_policy_document.policy-ekssa-ebs-csi-controller.json
  name               = var.name-role-ekssa-ebs-csi-controller
}

data "aws_iam_policy_document" "policy-ekssa-ebs-csi-controller" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role_policy_attachment" "role-ekssa-ebs-csi-controller-policya-1" {
  role       = aws_iam_role.role-ekssa-ebs-csi-controller.name
  policy_arn = aws_iam_policy.policy-ekssa-ebs-csi-controller.arn
}

resource "aws_iam_policy" "policy-ekssa-ebs-csi-controller" {
  name        = "policy-${var.name-role-ekssa-ebs-csi-controller}"
  path        = "/"
  description = "Policy for EBS CSI Controller IAM Role"
  policy = file("${path.module}/json/ebs-csi-controller-policy.json")
}