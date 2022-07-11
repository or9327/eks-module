#### IAM Role ####

# IAM Role for Fluent Bit 
resource "aws_iam_role" "role-ekssa-fluent-bit" {
  assume_role_policy = data.aws_iam_policy_document.policy-ekssa-fluent-bit.json
  name               = var.name-role-ekssa-fluent-bit
}

data "aws_iam_policy_document" "policy-ekssa-fluent-bit" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:amazon-cloudwatch:sa-fluent-bit"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role_policy_attachment" "role-ekssa-fluent-bit-policya-1" {
  role       = aws_iam_role.role-ekssa-fluent-bit.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "role-ekssa-fluent-bit-policya-2" {
  role       = aws_iam_role.role-ekssa-fluent-bit.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

