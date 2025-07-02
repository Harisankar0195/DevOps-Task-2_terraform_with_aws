output "instance_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.ec2_instance_for_DevOps_task.public_ip
}