# EKS Cluster and Node Group Configuration
# This Terraform configuration sets up an Amazon EKS cluster along with its associated IAM roles and node groups. It defines the necessary resources to create a fully functional EKS cluster, including the cluster itself, the IAM roles for both the cluster and the worker nodes, and the node groups that will run the workloads.

# aws_iam_role for the EKS cluster, allowing it to assume the necessary permissions to manage the cluster resources.
# assume_role_policy defines the trust relationship, allowing the EKS service to assume this role.
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# Attach the AmazonEKSClusterPolicy to the cluster IAM role, granting it the necessary permissions to manage EKS resources.
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# aws_eks_cluster resource defines the EKS cluster itself, specifying the cluster name, version, IAM role, and VPC configuration (subnet IDs).
# It also includes a dependency on the IAM role policy attachment to ensure that the necessary permissions are in place before creating the cluster.
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
}

# aws_iam_role for the worker nodes, allowing them to assume the necessary permissions to interact with the EKS cluster and other AWS services.
# service in the assume_role_policy is set to "ec2.amazonaws.com" since the worker nodes are EC2 instances that need to interact with the EKS cluster.
resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach necessary policies to the worker node IAM role, granting it permissions to interact with the EKS cluster and other AWS services.
# The policies attached include:
# - AmazonEKSWorkerNodePolicy: Grants permissions for worker nodes to interact with the EKS cluster.
# - AmazonEKS_CNI_Policy: Grants permissions for the Amazon EKS CNI plugin to manage network resources.
# - AmazonEC2ContainerRegistryReadOnly: Grants read-only access to the Amazon EC2 Container Registry (ECR).
resource "aws_iam_role_policy_attachment" "node_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  policy_arn = each.value
  role       = aws_iam_role.node.name
}


# aws_eks_node_group resource defines the node groups for the EKS cluster, specifying the cluster name, node group name, IAM role for the nodes, subnet IDs, instance types, capacity type, and scaling configuration.
# The node groups are created based on the input variable `node_groups`, allowing for dynamic configuration of multiple node groups with different settings.
# dependency on the IAM role policy attachment ensures that the necessary permissions are in place before creating the node groups.
# capacity_type can be set to either "ON_DEMAND" or "SPOT", depending on the desired cost and availability preferences for the worker nodes.
resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policy
  ]
}
