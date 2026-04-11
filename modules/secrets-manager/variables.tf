variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "producer_password" {
  type      = string
  sensitive = true
}

variable "consumer_password" {
  type      = string
  sensitive = true
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "Customer-managed KMS key ID for encryption. Uses AWS default key if null."
}
