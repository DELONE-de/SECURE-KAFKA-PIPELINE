output "function_arns" {
  description = "Map of Lambda function names to their ARNs"
  value       = { for k, v in aws_lambda_function.this : k => v.arn }
}

output "function_names" {
  description = "Map of Lambda function names"
  value       = { for k, v in aws_lambda_function.this : k => v.function_name }
}
