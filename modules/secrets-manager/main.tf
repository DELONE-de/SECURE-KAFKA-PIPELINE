locals {
  prefix = "${var.project_name}-${var.environment}"
}

# ─── Producer Secret ──────────────────────────────────────────────────────────

resource "aws_secretsmanager_secret" "producer" {
  name       = "${local.prefix}-producer-credentials"
  kms_key_id = var.kms_key_id

  tags = {
    Name        = "${local.prefix}-producer-credentials"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "producer" {
  secret_id = aws_secretsmanager_secret.producer.id

  secret_string = jsonencode({
    username = "producer"
    password = var.producer_password
  })
}

# ─── Consumer Secret ──────────────────────────────────────────────────────────

resource "aws_secretsmanager_secret" "consumer" {
  name       = "${local.prefix}-consumer-credentials"
  kms_key_id = var.kms_key_id

  tags = {
    Name        = "${local.prefix}-consumer-credentials"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "consumer" {
  secret_id = aws_secretsmanager_secret.consumer.id

  secret_string = jsonencode({
    username = "consumer"
    password = var.consumer_password
  })
}
