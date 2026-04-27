output "instance_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_eip.main.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}