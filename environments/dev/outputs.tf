# VPC
output "vpc_id"             { value = module.vpc.vpc_id }
output "private_subnet_ids" { value = module.vpc.private_subnet_ids }

# S3
output "bucket_name" { value = module.s3.bucket_name }

# MSK
output "msk_cluster_arn"              { value = module.msk.msk_cluster_arn }
output "bootstrap_brokers_sasl_scram" { value = module.msk.bootstrap_brokers_sasl_scram }

# EC2
output "ec2_instance_id" { value = module.ec2.ec2_instance_id }
output "ec2_private_ip"  { value = module.ec2.ec2_private_ip }

# Lambda
output "lambda_function_arn"     { value = module.lambda.lambda_function_arn }
output "lambda_function_name"    { value = module.lambda.lambda_function_name }
output "event_source_mapping_id" { value = module.lambda.event_source_mapping_id }

# IAM
output "ec2_role_arn"    { value = module.iam.ec2_role_arn }
output "lambda_role_arn" { value = module.iam.lambda_role_arn }

# Secrets
output "producer_secret_arn" { value = module.secrets.producer_secret_arn }
output "consumer_secret_arn" { value = module.secrets.consumer_secret_arn }

# CloudWatch
output "sns_topic_arn" { value = module.cloudwatch.sns_topic_arn }
