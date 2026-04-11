locals {
  bucket_name = var.bucket_name_prefix != "" ? "${var.bucket_name_prefix}-${var.project_name}-${var.environment}" : "${var.project_name}-${var.environment}-artifacts"
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  tags = {
    Name        = "${var.project_name}-${var.environment}-artifacts"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# ─── Package & Upload Artifacts ───────────────────────────────────────────────

resource "null_resource" "producer_install" {
  triggers = {
    deps = filemd5("${path.module}/../../services/producer/package.json")
  }

  provisioner "local-exec" {
    command     = "npm install --production"
    working_dir = "${path.module}/../../services/producer"
  }
}

resource "null_resource" "consumer_install" {
  triggers = {
    deps = filemd5("${path.module}/../../services/consumer/package.json")
  }

  provisioner "local-exec" {
    command     = "npm install --production"
    working_dir = "${path.module}/../../services/consumer"
  }
}

data "archive_file" "producer" {
  depends_on  = [null_resource.producer_install]
  type        = "zip"
  source_dir  = "${path.module}/../../services/producer"
  output_path = "${path.module}/../../services/producer.zip"
}

data "archive_file" "consumer" {
  depends_on  = [null_resource.consumer_install]
  type        = "zip"
  source_dir  = "${path.module}/../../services/consumer"
  output_path = "${path.module}/../../services/consumer.zip"
}

resource "aws_s3_object" "producer" {
  bucket = aws_s3_bucket.this.bucket
  key    = "producer/producer.zip"
  source = data.archive_file.producer.output_path
  etag   = data.archive_file.producer.output_md5

  tags = {
    Name        = "${var.project_name}-${var.environment}-producer-artifact"
    Environment = var.environment
  }
}

resource "aws_s3_object" "consumer" {
  bucket = aws_s3_bucket.this.bucket
  key    = "consumer/consumer.zip"
  source = data.archive_file.consumer.output_path
  etag   = data.archive_file.consumer.output_md5

  tags = {
    Name        = "${var.project_name}-${var.environment}-consumer-artifact"
    Environment = var.environment
  }
}
