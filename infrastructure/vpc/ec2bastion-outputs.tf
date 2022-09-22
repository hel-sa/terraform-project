output "ec2_bastion_public_instance_ids" {
  description = "List of ID instances"
  value = module.ec2_public.id
}

output "ec2_bastion_eip" {
  description = "Elastic IP of Bastion"
  value = aws_eip.bastion_eip.public_ip
}