cluster_name = "eksdevops"
cluster_service_ipv4_cidr = "172.20.0.0/16"
cluster_version = "1.23" #https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
cluster_endpoint_private_access = false
cluster_endpoint_public_access = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]