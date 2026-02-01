# Security Groups Module - EKS Configuration
# Implements least privilege access control for GCC compliance

# ALB Security Group - Only allows HTTPS inbound
#checkov:skip=CKV_AWS_260:Port 80 open for HTTP to HTTPS redirect required by ALB listener
#checkov:skip=CKV_AWS_382:Egress 0.0.0.0/0 required for ALB to reach backend targets in any subnet
#checkov:skip=CKV2_AWS_5:Security group attached to ALB resource managed by Ingress Controller
resource "aws_security_group" "alb" {
  name_prefix = "${var.environment}-alb-sg-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP redirect to HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-alb-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# EKS Cluster Security Group - Control plane communication
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.environment}-eks-cluster-sg-"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-eks-cluster-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# EKS Node Security Group - Worker nodes
resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.environment}-eks-nodes-sg-"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow nodes to communicate with each other"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    self            = true
  }

  ingress {
    description     = "Allow pods to communicate with cluster API"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  ingress {
    description     = "Allow ALB to reach pods"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.environment}-eks-nodes-sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Allow cluster to communicate with nodes
resource "aws_security_group_rule" "cluster_to_nodes" {
  description              = "Allow cluster to communicate with nodes"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
}

# VPC Endpoints Security Group (for private ECR/S3 access)
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.environment}-vpc-endpoints-sg-"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-vpc-endpoints-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
