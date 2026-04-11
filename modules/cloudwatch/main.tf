locals {
  prefix = "${var.project_name}-${var.environment}"
}

# ─── SNS Topic ────────────────────────────────────────────────────────────────

resource "aws_sns_topic" "alarms" {
  name = "${local.prefix}-alarms"

  tags = {
    Name        = "${local.prefix}-alarms"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# ─── Log Groups ───────────────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14

  tags = {
    Name        = "${local.prefix}-lambda-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "ec2" {
  name              = "/aws/ec2/${local.prefix}"
  retention_in_days = 14

  tags = {
    Name        = "${local.prefix}-ec2-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "msk" {
  name              = "/aws/msk/${local.prefix}"
  retention_in_days = 14

  tags = {
    Name        = "${local.prefix}-msk-logs"
    Environment = var.environment
  }
}

# ─── Lambda Alarms ────────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.prefix}-lambda-errors"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  dimensions          = { FunctionName = var.lambda_function_name }
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = var.lambda_error_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  tags = {
    Name        = "${local.prefix}-lambda-errors"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${local.prefix}-lambda-throttles"
  namespace           = "AWS/Lambda"
  metric_name         = "Throttles"
  dimensions          = { FunctionName = var.lambda_function_name }
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 10
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  tags = {
    Name        = "${local.prefix}-lambda-throttles"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${local.prefix}-lambda-duration"
  namespace           = "AWS/Lambda"
  metric_name         = "Duration"
  dimensions          = { FunctionName = var.lambda_function_name }
  statistic           = "p99"
  period              = 60
  evaluation_periods  = 3
  threshold           = 50000
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  tags = {
    Name        = "${local.prefix}-lambda-duration"
    Environment = var.environment
  }
}

# ─── EC2 Alarms ───────────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "${local.prefix}-ec2-cpu"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  dimensions          = { InstanceId = var.ec2_instance_id }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.ec2_cpu_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  tags = {
    Name        = "${local.prefix}-ec2-cpu"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_status" {
  alarm_name          = "${local.prefix}-ec2-status"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  dimensions          = { InstanceId = var.ec2_instance_id }
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  tags = {
    Name        = "${local.prefix}-ec2-status"
    Environment = var.environment
  }
}

# ─── MSK Alarms ───────────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "msk_consumer_lag" {
  alarm_name          = "${local.prefix}-msk-consumer-lag"
  namespace           = "AWS/Kafka"
  metric_name         = "SumOffsetLag"
  dimensions          = { ClusterName = var.msk_cluster_name }
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 3
  threshold           = var.msk_lag_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  tags = {
    Name        = "${local.prefix}-msk-consumer-lag"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "msk_disk" {
  alarm_name          = "${local.prefix}-msk-disk"
  namespace           = "AWS/Kafka"
  metric_name         = "KafkaDataLogsDiskUsed"
  dimensions          = { ClusterName = var.msk_cluster_name }
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 2
  threshold           = 85
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  tags = {
    Name        = "${local.prefix}-msk-disk"
    Environment = var.environment
  }
}
