output "producer_secret_arn" {
  value = aws_secretsmanager_secret.producer.arn
}

output "consumer_secret_arn" {
  value = aws_secretsmanager_secret.consumer.arn
}

output "all_secret_arns" {
  value = [
    aws_secretsmanager_secret.producer.arn,
    aws_secretsmanager_secret.consumer.arn,
  ]
}
