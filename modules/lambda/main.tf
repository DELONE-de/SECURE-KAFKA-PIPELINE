resource "aws_lambda_function" "consumer" {
  function_name = var.lambda_function_name
  role          = var.lambda_role_arn
  runtime       = "nodejs20.x"
  handler       = var.handler
  s3_bucket     = var.artifact_bucket
  s3_key        = var.artifact_key
  timeout       = var.timeout
  memory_size   = var.memory_size

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-lambda-consumer"
    Environment = var.environment
  }
}

resource "aws_lambda_event_source_mapping" "msk" {
  event_source_arn  = var.msk_cluster_arn
  function_name     = aws_lambda_function.consumer.arn
  topics            = [var.kafka_topic]
  starting_position = var.starting_position
  batch_size        = var.batch_size
  enabled           = true
}
