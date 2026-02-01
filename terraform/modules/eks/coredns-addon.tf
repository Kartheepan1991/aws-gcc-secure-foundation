# CoreDNS Addon Configuration for t3.micro (4 pod limit)
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"
  addon_version = "v1.11.3-eksbuild.2"  # Compatible with EKS 1.33
  
  configuration_values = jsonencode({
    replicaCount = 1  # Reduce from 2 to 1 for t3.micro pod limit
  })

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.main
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-coredns-addon"
    }
  )
}
