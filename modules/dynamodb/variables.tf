variable "table_name" { type = string }
variable "billing_mode" { type = string; default = "PAY_PER_REQUEST" }
variable "hash_key" { type = string; default = "messageId" }
variable "tags" { type = map(string); default = {} }
