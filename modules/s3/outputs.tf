output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "producer_artifact_key" {
  value = aws_s3_object.producer.key
}

output "consumer_artifact_key" {
  value = aws_s3_object.consumer.key
}
