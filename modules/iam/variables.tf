variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket the EC2 producer reads artifacts from"
}

variable "dynamodb_table_arn" {
  type        = string
  description = "ARN of the DynamoDB table the Lambda consumer writes to"
}

variable "secrets_arns" {
  type        = list(string)
  description = "List of Secrets Manager secret ARNs accessible by both roles"
}

variable "msk_cluster_arn" {
  type        = string
  description = "ARN of the MSK cluster the Lambda consumer reads from"
}
