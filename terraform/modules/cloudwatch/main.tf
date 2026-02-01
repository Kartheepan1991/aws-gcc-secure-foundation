# CloudWatch Module - Logging, monitoring, and alarms for GCC compliance

# Log Group for EKS cluster logs
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn  # null = AWS-managed encryption

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-eks-cluster-logs"
    }
  )
}

# Log Group for application logs
resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/eks/${var.cluster_name}/application"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn  # null = AWS-managed encryption

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-application-logs"
    }
  )
}

# Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${var.environment}-flow-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn  # null = AWS-managed encryption

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-vpc-flow-logs"
    }
  )
}

# Metric Filter - Failed authentication attempts
resource "aws_cloudwatch_log_metric_filter" "failed_auth" {
  name           = "${var.environment}-failed-authentication"
  log_group_name = aws_cloudwatch_log_group.eks_cluster.name
  pattern        = "[time, request_id, event_type = *Unauthorized* || event_type = *Forbidden*]"

  metric_transformation {
    name      = "FailedAuthenticationAttempts"
    namespace = "${var.environment}/Security"
    value     = "1"
  }
}

# Alarm - High failed authentication attempts
resource "aws_cloudwatch_metric_alarm" "failed_auth" {
  alarm_name          = "${var.environment}-high-failed-auth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FailedAuthenticationAttempts"
  namespace           = "${var.environment}/Security"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Alert on high number of failed authentication attempts"
  alarm_actions       = var.alarm_sns_topic_arns

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-failed-auth-alarm"
    }
  )
}

# Alarm - ALB unhealthy targets
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  count               = var.target_group_arn != "" ? 1 : 0
  alarm_name          = "${var.environment}-alb-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "Alert when ALB has unhealthy targets"
  alarm_actions       = var.alarm_sns_topic_arns

  dimensions = {
    TargetGroup  = split(":", var.target_group_arn)[5]
    LoadBalancer = var.load_balancer_arn_suffix
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-unhealthy-targets-alarm"
    }
  )
}

# Alarm - ALB 5XX errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  count               = var.load_balancer_arn_suffix != "" ? 1 : 0
  alarm_name          = "${var.environment}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Alert on high number of 5XX errors"
  alarm_actions       = var.alarm_sns_topic_arns

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-5xx-errors-alarm"
    }
  )
}

# Alarm - EKS node CPU utilization
resource "aws_cloudwatch_metric_alarm" "eks_node_cpu" {
  count               = length(var.node_group_names)
  alarm_name          = "${var.environment}-eks-node-cpu-${count.index}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when EKS node CPU utilization is high"
  alarm_actions       = var.alarm_sns_topic_arns

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-eks-node-cpu-alarm"
    }
  )
}

# Alarm - EKS pod failures
resource "aws_cloudwatch_metric_alarm" "eks_pod_failures" {
  alarm_name          = "${var.environment}-eks-pod-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "pod_number_of_container_restarts"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Alert on high number of pod restarts"
  alarm_actions       = var.alarm_sns_topic_arns

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-pod-failures-alarm"
    }
  )
}

# Dashboard for monitoring
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-monitoring-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average" }],
            [".", "RequestCount", { stat = "Sum" }],
            [".", "HTTPCode_Target_2XX_Count", { stat = "Sum" }],
            [".", "HTTPCode_Target_5XX_Count", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ALB Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["ContainerInsights", "node_cpu_utilization", { stat = "Average" }],
            [".", "node_memory_utilization", { stat = "Average" }],
            [".", "pod_cpu_utilization", { stat = "Average" }],
            [".", "pod_memory_utilization", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EKS Cluster Metrics"
        }
      }
    ]
  })
}
