variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for endpoint deployment"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
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

variable "endpoint_security_group_id" {
  description = "Security group ID for VPC endpoints (from security-groups module)"
  type        = string
}
