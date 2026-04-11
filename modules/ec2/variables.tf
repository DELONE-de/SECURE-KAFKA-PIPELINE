variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "subnet_id" {
  type = string
}

variable "ec2_security_group_id" {
  type = string
}

variable "artifact_bucket" {
  type        = string
  description = "S3 bucket name containing the producer artifact"
}

variable "artifact_key" {
  type        = string
  description = "S3 key for the producer artifact"
}

variable "iam_instance_profile_name" {
  type        = string
  description = "IAM instance profile name from the iam module"
}
