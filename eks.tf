resource "aws_iam_role" "cluster_iam_role" {
  name               = "${var.project_name}-${var.project_env}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cluster-policy" {
  role       = aws_iam_role.cluster_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_iam_role" "worker_iam_role" {
  name               = "${var.project_name}-${var.project_env}-worker-role"
  assume_role_policy = data.aws_iam_policy_document.worker_assume_role.json
}

resource "aws_iam_role_policy_attachment" "worker-policy" {
  for_each   = var.worker_policy_arns
  role       = aws_iam_role.worker_iam_role.name
  policy_arn = each.value
}

resource "aws_eks_cluster" "wp-eks-cluster" {
  name     = "${var.project_name}-${var.project_env}-cluster"
  role_arn = aws_iam_role.cluster_iam_role.arn
  version  = "1.28"

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    subnet_ids              = flatten([aws_subnet.public_subnets[*].id, aws_subnet.private_subnets[*].id])
    public_access_cidrs     = ["0.0.0.0/0"]
  }
  tags = merge(var.common-tags, {
    "Name" = "${var.project_name}-${var.project_env}-cluster"
  })
  depends_on = [aws_iam_role_policy_attachment.cluster-policy]
}

resource "aws_eks_node_group" "wp-node-group" {
  cluster_name    = aws_eks_cluster.wp-eks-cluster.name
  node_group_name = "${var.project_name}-${var.project_env}-node-group"
  node_role_arn   = aws_iam_role.worker_iam_role.arn
  subnet_ids      = aws_subnet.private_subnets[*].id

  scaling_config {
    desired_size = var.nodegroup_desired_size
    max_size     = var.nodegroup_max_size
    min_size     = var.nodegroup_min_size
  }

  update_config {
    max_unavailable = var.nodegroup_max_unavailable
  }

  ami_type       = "AL2_x86_64"
  instance_types = [var.nodegroup_instance_type]
  capacity_type  = "ON_DEMAND"
  disk_size      = 20
  tags = merge(var.common-tags, {
    "Name" = "${var.project_name}-${var.project_env}-node-group"
  })
  depends_on = [aws_iam_role_policy_attachment.worker-policy]
}