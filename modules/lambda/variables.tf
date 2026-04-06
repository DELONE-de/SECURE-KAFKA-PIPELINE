variable "functions" {
  description = "Map of Lambda function names to their config (filename, env_vars)"
  type        = map(any)
}

variable "lambda_role_arn" {
  description = "IAM role ARN for Lambda execution"
  type        = string
}

variable "kafka_bootstrap_servers" {
  description = "MSK bootstrap broker string"
  type        = string
}

variable "secret_arn" {
  description = "Secrets Manager ARN for Kafka credentials"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for Lambda VPC config"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for Lambda VPC config"
  type        = list(string)
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
