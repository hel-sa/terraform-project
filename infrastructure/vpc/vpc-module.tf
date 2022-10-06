#AZs dynamically
data "aws_availability_zones" "available" {
  #state = "available"
  exclude_names = [ "eu-west-2c" ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

  name = "${local.name}-${var.vpc_name}"
  cidr = var.vpc_cidr_block

  #azs                 = var.vpc_availability_zones
  azs = data.aws_availability_zones.available.names
  private_subnets     = var.vpc_public_subnets
  public_subnets      = var.vpc_private_subnets

  #DB Subnets
  create_database_subnet_group = var.vpc_create_database_subnet_group
  create_database_subnet_route_table = var.vpc_create_database_subnet_route_table
  database_subnets    = var.vpc_database_subnets
  #We don't need public communication for our db now
  #create_database_nat_gateway_route = true
  #create_database_internet_gateway_route = true 

  #NAT Gateway for outbound communication
  enable_nat_gateway = var.vpc_enable_nat_gateway
  #Only for testing
  #in production environment we may need more than one
  single_nat_gateway = var.vpc_single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support = true

  # Additional Tags to Subnets
  public_subnet_tags = {
    Type = "Public Subnets"
    "kubernetes.io/role/elb" = 1    
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"        
  }
  private_subnet_tags = {
    Type = "private-subnets"
    "kubernetes.io/role/internal-elb" = 1    
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"    
  }

  database_subnet_tags = {
    Type = "database-subnets"
  }

  vpc_tags = local.common_tags
}
