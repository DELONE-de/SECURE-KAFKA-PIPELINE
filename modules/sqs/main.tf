resource "aws_sqs_queue" "this" {
  name                      = var.queue_name
  visibility_timeout_seconds = var.visibility_timeout
  tags                      = var.tags
}
