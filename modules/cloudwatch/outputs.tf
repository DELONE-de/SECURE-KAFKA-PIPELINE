output "sns_topic_arn" {
  value = aws_sns_topic.alarms.arn
}

output "lambda_log_group_name" {
  value = aws_cloudwatch_log_group.lambda.name
}

output "ec2_log_group_name" {
  value = aws_cloudwatch_log_group.ec2.name
}

output "msk_log_group_name" {
  value = aws_cloudwatch_log_group.msk.name
}
