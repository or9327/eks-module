#### IAM Role ####

# IAM Role for CloudWatch Agent
resource "aws_iam_role" "role-ekssa-cloudwatch-agent" {
  assume_role_policy = data.aws_iam_policy_document.policy-ekssa-cloudwatch-agent.json
  name               = var.name-role-ekssa-cloudwatch-agent
}

data "aws_iam_policy_document" "policy-ekssa-cloudwatch-agent" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:amazon-cloudwatch:sa-cloudwatch-agent"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role_policy_attachment" "role-ekssa-cloudwatch-agent-policya-1" {
  role       = aws_iam_role.role-ekssa-cloudwatch-agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "role-ekssa-cloudwatch-agent-policya-2" {
  role       = aws_iam_role.role-ekssa-cloudwatch-agent.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

