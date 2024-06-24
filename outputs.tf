output "ec2_rhel_instance_id" {
  value = aws_instance.ec2_instance.id
}

output "ec2_rhel_instance_public_dns" {
  value = aws_instance.ec2_instance.public_dns
}

output "ec2_rhel_instance_public_ip" {
  value = aws_eip.ec2_eip.public_ip
}

output "ec2_rhel_instance_private_ip" {
  value = aws_instance.ec2_instance.private_ip
}