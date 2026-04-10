variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for MSK brokers (one per AZ)"
  type        = list(string)
}

variable "msk_security_group_id" {
  description = "Security group ID to attach to MSK brokers"
  type        = string
}

variable "project_name" {
  description = "Project name for naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the MSK cluster"
  type        = string
}

variable "kafka_version" {
  description = "Kafka version to deploy"
  type        = string
  default     = "3.5.1"
}

variable "broker_instance_type" {
  description = "MSK broker instance type"
  type        = string
  default     = "kafka.m5.large"
}

variable "broker_volume_size" {
  description = "EBS volume size (GiB) per broker"
  type        = number
  default     = 100
}

variable "producer_secret_arn" {
  description = "ARN of the Secrets Manager secret for the producer (SASL/SCRAM)"
  type        = string
}

variable "consumer_secret_arn" {
  description = "ARN of the Secrets Manager secret for the consumer (SASL/SCRAM)"
  type        = string
}

variable "cloudwatch_log_group" {
  description = "CloudWatch log group name for MSK broker logs"
  type        = string
}
