output "ec2_instance_id" {
  value = aws_instance.producer.id
}

output "ec2_private_ip" {
  value = aws_instance.producer.private_ip
}
