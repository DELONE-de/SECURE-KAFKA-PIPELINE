variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for the 3 private subnets"
  type        = list(string)
  validation {
    condition     = length(var.private_subnet_cidrs) == 3
    error_message = "Exactly 3 private subnet CIDRs must be provided."
  }
}

variable "availability_zones" {
  description = "List of 3 availability zones"
  type        = list(string)
  validation {
    condition     = length(var.availability_zones) == 3
    error_message = "Exactly 3 availability zones must be provided."
  }
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}
