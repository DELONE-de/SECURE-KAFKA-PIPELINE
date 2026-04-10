output "secretsmanager_endpoint_id" {
  description = "ID of the Secrets Manager VPC endpoint"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "ssm_endpoint_id" {
  description = "ID of the SSM VPC endpoint"
  value       = aws_vpc_endpoint.ssm.id
}

output "logs_endpoint_id" {
  description = "ID of the CloudWatch Logs VPC endpoint"
  value       = aws_vpc_endpoint.logs.id
}

output "endpoint_security_group_id" {
  description = "ID of the security group attached to VPC endpoints"
  value       = aws_security_group.endpoints.id
}
