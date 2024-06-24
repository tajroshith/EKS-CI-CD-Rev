variable "vpc_cidr" {
  description = "cidr block for main vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "common-tags" {
  description = "common-tags for resources"
  type        = map(string)
  default = {
    "Team" = "DevOps"
  }
}

variable "project_name" {
  description = "Name for the project"
  type        = string
  default     = "EKS"
}

variable "project_env" {
  description = "Enviornment of the project"
  type        = string
  default     = "Dev"
}

variable "public_subnets_cidr" {
  description = "cidr blocks for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
}

variable "private_subnets_cidr" {
  description = "cidr blocks for private subnets"
  type        = list(string)
  default     = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]
}

variable "map_public_ip_on_launch_public" {
  description = "Enable / Disable public IP in subnets"
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch_private" {
  description = "Enable / Disable public IP in subnets"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Enable / Disable dns support"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable / Disable dns hostnames"
  type        = bool
  default     = true
}

variable "worker_policy_arns" {
  description = "Set of worker policy arn's"
  type        = set(string)
  default = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}

variable "endpoint_private_access" {
  description = "Enable Disable private endpoint access"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable Disable public endpoint access"
  type        = bool
  default     = true
}

variable "nodegroup_desired_size" {
  description = "Desired size of instances for nodegroup"
  type        = number
  default     = 2
}

variable "nodegroup_max_size" {
  type    = number
  default = 2
}

variable "nodegroup_min_size" {
  type    = number
  default = 1
}

variable "nodegroup_max_unavailable" {
  type    = number
  default = 1
}

variable "nodegroup_instance_type" {
  type    = string
  default = "t2.medium"
}