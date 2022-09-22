#Bad Practice!! Normally we use ssh-agent to connect through a Bastion host
#Education purpose use case

#Use Case: Copy ec2 key-pair from our local working directory to the newly created bastion host
#Null Resource
resource "null_resource" "copy_ec2_keys" {
  depends_on = [
    module.ec2_public
  ] #only when ec2 instances is created this will be invoked
}

connection {
  type = "ssh"
  host = aws_eip.bastion_eip.public_ip 
  user = "ec2-user"
  password = ""
  private_key = file("private-key/eks-terraform-key.pem")
}

provisioner "file" {
  source = "private-key/eks-terraform-key.pem"
  destination = "/tmp/eks-terraform-key.pem"
}

provisioner "remote-exec" {
  inline = [
    "sudo chmod 400 /tmp/eks-terraform-key.pem"
  ]
}

#This can run either during creation time of resource or deletion
#stores locally
#runs on our local desktop
/*
provisioner "local-exec" {
  command = "echo VPC ID: ${module.vpc.vpc_id} >> creation-time-vpc-id.txt"
}*/