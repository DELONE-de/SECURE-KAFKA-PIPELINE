output "lambda_function_arn" {
  value = aws_lambda_function.consumer.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.consumer.function_name
}

output "event_source_mapping_id" {
  value = aws_lambda_event_source_mapping.msk.id
}
