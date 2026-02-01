# EKS Cluster Module - Production-ready with GCC compliance
# Implements encryption, logging, and security best practices

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.environment}-eks-cluster"
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = var.enable_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = [var.cluster_security_group_id]
  }

  # Enable all control plane logging for GCC compliance
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # Using AWS-managed encryption for secrets
  # encryption_config removed to avoid KMS key state issues

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-eks-cluster"
    }
  )

  depends_on = [
    var.cluster_log_group_name
  ]
}

# OIDC Provider for IRSA (IAM Roles for Service Accounts)
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-eks-oidc-provider"
    }
  )
}

# EKS Managed Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name_prefix = "${var.environment}-node-group-"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  version         = var.cluster_version

  scaling_config {
    desired_size = var.desired_nodes
    max_size     = var.max_nodes
    min_size     = var.min_nodes
  }

  instance_types = var.instance_types
  capacity_type  = var.capacity_type

  # Launch template for advanced configuration (disk_size defined in template)
  launch_template {
    id      = aws_launch_template.node.id
    version = aws_launch_template.node.latest_version
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    Environment = var.environment
    NodeGroup   = "main"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-eks-node-group"
    }
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }

  depends_on = [aws_eks_cluster.main]
}

# Launch Template for EKS nodes with encrypted EBS volumes
resource "aws_launch_template" "node" {
  name_prefix = "${var.environment}-eks-node-"
  description = "Launch template for EKS nodes"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.node_disk_size
      volume_type           = "gp3"
      encrypted             = true
      # Using AWS-managed encryption (no KMS key)
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "${var.environment}-eks-node"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      {
        Name = "${var.environment}-eks-node-volume"
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-eks-node-launch-template"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# EKS Add-on: VPC CNI (uses default IAM role)
resource "aws_eks_addon" "vpc_cni" {
  cluster_name              = aws_eks_cluster.main.name
  addon_name                = "vpc-cni"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-vpc-cni-addon"
    }
  )

  depends_on = [aws_eks_node_group.main]
}

# EKS Add-on: CoreDNS
resource "aws_eks_addon" "coredns" {
  cluster_name              = aws_eks_cluster.main.name
  addon_name                = "coredns"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-coredns-addon"
    }
  )

  depends_on = [aws_eks_node_group.main]
}

# EKS Add-on: kube-proxy
resource "aws_eks_addon" "kube_proxy" {
  cluster_name              = aws_eks_cluster.main.name
  addon_name                = "kube-proxy"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-kube-proxy-addon"
    }
  )

  depends_on = [aws_eks_node_group.main]
}

# EKS Add-on: EBS CSI Driver for persistent volumes (optional, uses default role)
resource "aws_eks_addon" "ebs_csi_driver" {
  count = var.enable_ebs_csi_driver ? 1 : 0

  cluster_name              = aws_eks_cluster.main.name
  addon_name                = "aws-ebs-csi-driver"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-ebs-csi-addon"
    }
  )

  depends_on = [aws_eks_node_group.main]
}
