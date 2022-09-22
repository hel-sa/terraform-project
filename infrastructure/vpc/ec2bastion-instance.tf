#AWS EC2 Security Group Terraform Module used

#EC2 Instance - Bastion Host on public subnet
module "ec2_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.1.4"

  name = "${local.name}-Bastion-Host"

  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type
  key_name               = var.instance_keypair
  #monitoring             = true
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = local.common_tags
}

#Security Group for Public Bastion Host
module "public_bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"

  name        = "${local.name}-public_bastion_sg"
  description = "Security group SSH open from Anywhere - egress all open"
  vpc_id      = module.vpc.vpc_id
  
  #Ingress Rules
  ingress_rules = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"] #from anywhere
  
  #Egress Rules - all open
  egress_rules = ["all-all"]

  tags = local.common_tags
}

#Elastic ip for bastion host
resource "aws_eip" "bastion_eip" {
  instance = module.ec2_public.id
  vpc = true

  depends_on = [module.ec2_public, 
    module.vpc
  ]

    tags = local.common_tags
}