project_name = "EKS"
project_env = "Dev"
common-tags = {
    "Env" = "Development"
    "Team" = "DevOps"
}

vpc_cidr = "172.22.0.0/16"
public_subnets_cidr = [ "172.22.0.0/19", "172.22.32.0/19", "172.22.64.0/19"]
private_subnets_cidr = [ "172.22.96.0/19", "172.22.128.0/19", "172.22.160.0/19"]
nodegroup_instance_type = "t2.medium"
nodegroup_desired_size = 2
nodegroup_max_size = 2
nodegroup_min_size = 1
nodegroup_max_unavailable = 1
