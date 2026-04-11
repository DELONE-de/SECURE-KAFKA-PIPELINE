variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "artifact_bucket" {
  type = string
}

variable "artifact_key" {
  type = string
}

variable "handler" {
  type    = string
  default = "src/handler.handler"
}

variable "timeout" {
  type    = number
  default = 60
}

variable "memory_size" {
  type    = number
  default = 256
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "lambda_security_group_id" {
  type = string
}

variable "msk_cluster_arn" {
  type = string
}

variable "kafka_topic" {
  type    = string
  default = "events"
}

variable "batch_size" {
  type    = number
  default = 100
}

variable "starting_position" {
  type    = string
  default = "LATEST"
}

variable "dynamodb_table_name" {
  type = string
}
