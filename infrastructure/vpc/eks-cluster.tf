#EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${local.name}-${var.cluster_name}"
  role_arn = aws_iam_role.eks_master_role.arn
  version = var.cluster_version

  
  vpc_config {
    subnet_ids = module.vpc.public_subnets #Where the cluster's inerfaces are going to be created in
    endpoint_private_access = var.cluster_endpoint_private_access #false
    endpoint_public_access  = var.cluster_endpoint_public_access  #true
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs #open for anyone -> eks.auto.tfvars
  }
  #Optional config
  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }
  #Enable EKS Cluster Control Plane Logging 
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  #EKS cluster has to be created once these policies are attached to role
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
}

#IAM Role for cluster

#IAM Role create
resource "aws_iam_role" "eks_master_role" {
  name = "${local.name}-eks-master-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

#Policy to Role association
#two policies predefined in AWS for EKS (aws managed policies)
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  #This policy provides Kubernetes the permissions it requires to manage resources on your behalf
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  #Policy used by VPC Resource Controller to manage ENI and IPs for worker nodes
  #creates elastic network interfaces inside our vpc (this way it will get the permissions)
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.name
}