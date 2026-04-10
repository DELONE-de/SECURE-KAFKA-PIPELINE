locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Environment = var.environment
  }
}

resource "aws_security_group" "ec2" {
  name        = "${local.name_prefix}-ec2-sg"
  description = "EC2 producer: outbound to MSK and VPC endpoints only"
  vpc_id      = var.vpc_id

  egress {
    description     = "Kafka TLS to MSK"
    from_port       = 9094
    to_port         = 9094
    protocol        = "tcp"
    security_groups = [aws_security_group.msk.id]
  }

  egress {
    description     = "HTTPS to VPC endpoints"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.sg_vpc_endpoints_id]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2-sg"
  })
}

resource "aws_security_group" "lambda" {
  name        = "${local.name_prefix}-lambda-sg"
  description = "Lambda consumer: outbound to MSK and VPC endpoints only"
  vpc_id      = var.vpc_id

  egress {
    description     = "Kafka TLS to MSK"
    from_port       = 9094
    to_port         = 9094
    protocol        = "tcp"
    security_groups = [aws_security_group.msk.id]
  }

  egress {
    description     = "HTTPS to VPC endpoints"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.sg_vpc_endpoints_id]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-lambda-sg"
  })
}

resource "aws_security_group" "msk" {
  name        = "${local.name_prefix}-msk-sg"
  description = "MSK cluster: Kafka TLS inbound from EC2 and Lambda only"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-msk-sg"
  })
}

resource "aws_security_group_rule" "msk_inbound_ec2" {
  description              = "Kafka TLS from EC2"
  type                     = "ingress"
  from_port                = 9094
  to_port                  = 9094
  protocol                 = "tcp"
  security_group_id        = aws_security_group.msk.id
  source_security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "msk_inbound_lambda" {
  description              = "Kafka TLS from Lambda"
  type                     = "ingress"
  from_port                = 9094
  to_port                  = 9094
  protocol                 = "tcp"
  security_group_id        = aws_security_group.msk.id
  source_security_group_id = aws_security_group.lambda.id
}
