data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "producer" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.ec2_security_group_id]
  iam_instance_profile        = var.iam_instance_profile_name
  associate_public_ip_address = false

  user_data = <<-EOF
    #!/bin/bash
    set -e

    yum update -y
    yum install -y unzip aws-cli

    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs

    mkdir -p /opt/producer
    aws s3 cp s3://${var.artifact_bucket}/${var.artifact_key} /opt/producer.zip
    unzip -o /opt/producer.zip -d /opt/producer
    cd /opt/producer && npm install --production

    cat > /etc/systemd/system/producer.service <<SERVICE
    [Unit]
    Description=Kafka Producer Service
    After=network.target

    [Service]
    ExecStart=/usr/bin/node /opt/producer/src/producer.js
    Restart=on-failure
    RestartSec=5
    WorkingDirectory=/opt/producer
    StandardOutput=journal
    StandardError=journal

    [Install]
    WantedBy=multi-user.target
    SERVICE

    systemctl daemon-reload
    systemctl enable producer
    systemctl start producer
  EOF

  tags = {
    Name        = "${var.project_name}-${var.environment}-producer"
    Environment = var.environment
  }
}
