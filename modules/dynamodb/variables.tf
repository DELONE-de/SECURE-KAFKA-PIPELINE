variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "table_name" {
  type = string
}

variable "billing_mode" {
  type    = string
  default = "PAY_PER_REQUEST"
}

variable "hash_key" {
  type    = string
  default = "eventId"
}

variable "range_key" {
  type    = string
  default = "timestamp"
}

variable "ttl_attribute" {
  type    = string
  default = "expiresAt"
}
