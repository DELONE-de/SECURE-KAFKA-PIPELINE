variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "ec2_instance_id" {
  type = string
}

variable "msk_cluster_name" {
  type = string
}

variable "alarm_email" {
  type        = string
  description = "Email address to receive CloudWatch alarm notifications"
}

variable "lambda_error_threshold" {
  type    = number
  default = 5
}

variable "ec2_cpu_threshold" {
  type    = number
  default = 80
}

variable "msk_lag_threshold" {
  type    = number
  default = 1000
}
