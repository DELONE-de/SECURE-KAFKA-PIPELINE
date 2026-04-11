locals {
  prefix = "${var.project_name}-${var.environment}"
}

# ─── EC2 (Producer) ───────────────────────────────────────────────────────────

resource "aws_iam_role" "ec2" {
  name = "${local.prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${local.prefix}-ec2-role"
    Environment = var.environment
  }
}

resource "aws_iam_policy" "ec2" {
  name = "${local.prefix}-ec2-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${var.s3_bucket_arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = var.secrets_arns
      },
      {
        Effect   = "Allow"
        Action   = ["ssm:*"]
        Resource = "arn:aws:ssm:*:*:parameter/${local.prefix}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/ec2/${local.prefix}*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2.arn
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
}

# ─── Lambda (Consumer) ────────────────────────────────────────────────────────

resource "aws_iam_role" "lambda" {
  name = "${local.prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${local.prefix}-lambda-role"
    Environment = var.environment
  }
}

resource "aws_iam_policy" "lambda" {
  name = "${local.prefix}-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = var.dynamodb_table_arn
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = var.secrets_arns
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/lambda/${local.prefix}*"
      },
      {
        Effect = "Allow"
        Action = ["kafka-cluster:*"]
        Resource = [
          var.msk_cluster_arn,
          "${var.msk_cluster_arn}/*"
        ]
      },
      {
        # Required for Lambda VPC + MSK event source mapping
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "kafka:DescribeCluster",
          "kafka:GetBootstrapBrokers",
          "kafka:ListTopics"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}
