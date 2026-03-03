# EKS Cluster

**Requried components and code explalation.**
- We need two(2) IAM roles, one for Cluster and other one for Node.
- Create a IAM role, attach policy to it.
- Create cluster, assign the role created.
- Will repeate the same for both master and worker node.

## IAM Role Resource
```hcl
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
```
- An IAM role is created, this role will be used by EKS control plane.
- EKS itself needs permission to create load balancers, manage networking and talk to other aws services.
- Service = "eks.amazonaws.com" --> Allows the EKS service to assume this role.

## Attach Policy resource 
```hcl
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}
```
- It attaches AWS-managed policy to the role just created.
- role = aws_iam_role.cluster.name --> this connectes IAM roles with policy, now EKS has requried permissions.

## EKS Clouster Createion
```hcl
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
```
- This creates the actual Kubernetes control plane
- role_arn = aws_iam_role.cluster.arn --> This connects the EKS cluster with IAM role.
- subnet_ids = var.subnet_ids --> This tells EKS to Deploy cluster inside these Subnets.
- depends_on block --> This forces the terraform to Create IAM role, attach policy and then create EKS 

## IAM Role for Worker Nodes
```hcl
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
```
- This role is for EC2 instances (worker nodes)
- Important deiiference is that, this allows the EC2 to assume roles **NOT the EKS**
  
## Reaource to attach Policies to Node's IAM Role
```hcl
resource "aws_iam_role_policy_attachment" "node_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  policy_arn = each.value
  role       = aws_iam_role.node.name
}
```
- We are attaching more policies to this worker nodes.
- WorkerNodePolicy --> Worker node communication with cluster
- CNI_Policy --> CNI networking
- EC2ContainerRegistryReadOnly --> Pull Docker images from ECR

## EKS Node Group
```hcl
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
```
- This creates EC2 worker nodes within the Cluster
- cluster_name --> Connects to EKS cluster.
- node_role_arn --> Connectes EC2 to IAM role.
- subnet_ids --> Worker nodes are deployed inside this VPC subnet.
- scaling_config block --> This controles auto scaling.
- depends_on block --> policy attached first then node group is created.
