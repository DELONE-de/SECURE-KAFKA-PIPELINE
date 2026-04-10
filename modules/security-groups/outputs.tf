output "ec2_security_group_id" {
  description = "ID of the EC2 producer security group"
  value       = aws_security_group.ec2.id
}

output "lambda_security_group_id" {
  description = "ID of the Lambda consumer security group"
  value       = aws_security_group.lambda.id
}

output "msk_security_group_id" {
  description = "ID of the MSK cluster security group"
  value       = aws_security_group.msk.id
}
