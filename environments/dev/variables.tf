variable "project_name" {
  type    = string
  default = "secure-kafka"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

# VPC
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# EC2
variable "instance_type" {
  type    = string
  default = "t3.small"
}

# Secrets
variable "producer_password" {
  type      = string
  sensitive = true
}

variable "consumer_password" {
  type      = string
  sensitive = true
}

# CloudWatch
variable "alarm_email" {
  type = string
}
