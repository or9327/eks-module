#### IAM Role ####

# IAM Role for EFS CSI Controller
resource "aws_iam_role" "role-ekssa-efs-csi-controller" {
  assume_role_policy = data.aws_iam_policy_document.policy-ekssa-efs-csi-controller.json
  name               = var.name-role-ekssa-efs-csi-controller
}

data "aws_iam_policy_document" "policy-ekssa-efs-csi-controller" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role_policy_attachment" "role-ekssa-efs-csi-controller-policya-1" {
  role       = aws_iam_role.role-ekssa-efs-csi-controller.name
  policy_arn = aws_iam_policy.policy-ekssa-efs-csi-controller.arn
}

resource "aws_iam_policy" "policy-ekssa-efs-csi-controller" {
  name        = "policy-${var.name-role-ekssa-efs-csi-controller}"
  path        = "/"
  description = "Policy for EFS CSI Controller IAM Role"
  policy = file("${path.module}/json/efs-csi-controller-policy.json")
}