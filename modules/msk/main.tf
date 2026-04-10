locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Name        = "${local.name_prefix}-msk"
    Environment = var.environment
  }
}

# ── KMS ──────────────────────────────────────────────────────────────────────

resource "aws_kms_key" "msk" {
  description             = "CMK for MSK encryption at rest"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = local.common_tags
}

resource "aws_kms_alias" "msk" {
  name          = "alias/${local.name_prefix}-msk"
  target_key_id = aws_kms_key.msk.key_id
}

# ── MSK CLUSTER ───────────────────────────────────────────────────────────────

resource "aws_msk_cluster" "this" {
  cluster_name           = var.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = var.broker_instance_type
    client_subnets  = var.private_subnet_ids
    security_groups = [var.msk_security_group_id]

    storage_info {
      ebs_storage_info {
        volume_size = var.broker_volume_size
      }
    }
  }

  client_authentication {
    sasl {
      scram = true
    }
    tls {}
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.msk.arn
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  enhanced_monitoring = "PER_BROKER"

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = var.cloudwatch_log_group
      }
    }
  }

  tags = local.common_tags
}

# ── SCRAM SECRET ASSOCIATION ──────────────────────────────────────────────────

resource "aws_msk_scram_secret_association" "this" {
  cluster_arn     = aws_msk_cluster.this.arn
  secret_arn_list = [var.producer_secret_arn, var.consumer_secret_arn]
}
