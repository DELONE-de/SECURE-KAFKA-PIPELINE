variable "queue_name"         { type = string }
variable "visibility_timeout" { type = number; default = 30 }
variable "tags"               { type = map(string); default = {} }
