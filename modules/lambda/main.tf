resource "aws_lambda_function" "this" {
  for_each = var.functions

  function_name = each.key
  role          = var.lambda_role_arn
  runtime       = "nodejs20.x"
  handler       = "${each.key}.handler"
  filename      = each.value.filename

  environment {
    variables = merge(
      {
        KAFKA_BOOTSTRAP_SERVERS = var.kafka_bootstrap_servers
        SECRET_ARN              = var.secret_arn
      },
      lookup(each.value, "env_vars", {})
    )
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tags = var.tags
}
