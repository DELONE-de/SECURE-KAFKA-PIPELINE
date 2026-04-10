output "bootstrap_brokers_sasl_scram" {
  description = "SASL/SCRAM bootstrap broker endpoints"
  value       = aws_msk_cluster.this.bootstrap_brokers_sasl_scram
}

output "bootstrap_brokers_tls" {
  description = "TLS bootstrap broker endpoints"
  value       = aws_msk_cluster.this.bootstrap_brokers_tls
}

output "zookeeper_connect_string" {
  description = "ZooKeeper connection string"
  value       = aws_msk_cluster.this.zookeeper_connect_string
}

output "msk_cluster_arn" {
  description = "ARN of the MSK cluster"
  value       = aws_msk_cluster.this.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for MSK encryption at rest"
  value       = aws_kms_key.msk.arn
}
