# Tema SNS para notificaciones de alarmas de CloudWatch
resource "aws_sns_topic" "cloudwatch_alarms" {
  name = "${var.project_name}-cloudwatch-alarms"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

#######################
# Alarmas de EC2
#######################

# Alarma de utilizacion de CPU de EC2 - para cada instancia
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  for_each = toset(var.ec2_instance_ids)
  
  alarm_name          = "${var.project_name}-ec2-high-cpu-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300  # 5 minutos
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Esta metrica monitorea la utilizacion de CPU de EC2"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  
  dimensions = {
    InstanceId = each.value
  }
}

# Alarma de chequeo de estado de EC2 - para cada instancia
resource "aws_cloudwatch_metric_alarm" "ec2_status" {
  for_each = toset(var.ec2_instance_ids)
  
  alarm_name          = "${var.project_name}-ec2-status-check-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60  # 1 minuto
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Esta metrica monitorea los chequeos de estado de EC2"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  
  dimensions = {
    InstanceId = each.value
  }
}

# La utilizacion de memoria requiere CloudWatch Agent, se agregara metrica personalizada para memoria
resource "aws_cloudwatch_metric_alarm" "ec2_memory" {
  for_each = toset(var.ec2_instance_ids)
  
  alarm_name          = "${var.project_name}-ec2-high-memory-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 300  # 5 minutos
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Esta metrica monitorea la utilizacion de memoria de EC2"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  
  dimensions = {
    InstanceId = each.value
  }
}

#######################
# Alarmas de RDS
#######################

# Alarma de utilizacion de CPU de RDS
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project_name}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300  # 5 minutos
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Esta metrica monitorea la utilizacion de CPU de RDS"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}

# Alarma de espacio de almacenamiento de RDS
resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "${var.project_name}-rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300  # 5 minutos
  statistic           = "Average"
  threshold           = 5000000000  # 5GB en bytes
  alarm_description   = "Esta metrica monitorea el espacio libre de almacenamiento de RDS"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}

# Alarma de conteo de conexiones de RDS
resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "${var.project_name}-rds-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300  # 5 minutos
  statistic           = "Average"
  threshold           = 100  # Ajustar segun el tamaño de la instancia de base de datos
  alarm_description   = "Esta metrica monitorea el conteo de conexiones de RDS"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}

#######################
# Alarmas de ALB
#######################

# Alarma de tasa de errores HTTP 5XX de ALB
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300  # 5 minutos
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Esta metrica monitorea los errores 5XX de ALB"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  
  dimensions = {
    LoadBalancer = var.lb_arn_suffix
  }
}

# Latencia de ALB (Tiempo de respuesta del objetivo) - Grupo objetivo web
resource "aws_cloudwatch_metric_alarm" "alb_latency_web" {
  alarm_name          = "${var.project_name}-alb-high-latency-web"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300  # 5 minutos
  statistic           = "Average"
  threshold           = 1    # 1 segundo
  alarm_description   = "Esta metrica monitorea el tiempo de respuesta del objetivo de ALB para web"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  
  dimensions = {
    LoadBalancer = var.lb_arn_suffix
    TargetGroup  = var.target_group_web_arn_suffix
  }
}

# Latencia de ALB (Tiempo de respuesta del objetivo) - Grupo objetivo de streaming
resource "aws_cloudwatch_metric_alarm" "alb_latency_streaming" {
  alarm_name          = "${var.project_name}-alb-high-latency-streaming"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300  # 5 minutos
  statistic           = "Average"
  threshold           = 1    # 1 segundo
  alarm_description   = "Esta metrica monitorea el tiempo de respuesta del objetivo de ALB para streaming"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  
  dimensions = {
    LoadBalancer = var.lb_arn_suffix
    TargetGroup  = var.target_group_streaming_arn_suffix
  }
}

# Hosts no "saludables" de ALB - Grupo objetivo web
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts_web" {
  alarm_name          = "${var.project_name}-alb-unhealthy-hosts-web"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300  # 5 minutos
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Esta metrica monitorea los hosts no saludables de ALB para web"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  
  dimensions = {
    LoadBalancer = var.lb_arn_suffix
    TargetGroup  = var.target_group_web_arn_suffix
  }
}

# Hosts no saludables de ALB - Grupo objetivo de streaming
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts_streaming" {
  alarm_name          = "${var.project_name}-alb-unhealthy-hosts-streaming"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300  # 5 minutos
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Esta metrica monitorea los hosts no saludables de ALB para streaming"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  
  dimensions = {
    LoadBalancer = var.lb_arn_suffix
    TargetGroup  = var.target_group_streaming_arn_suffix
  }
}

#######################
# CloudWatch Dashboard
#######################

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.project_name
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            for instance_id in var.ec2_instance_ids :
            ["AWS/EC2", "CPUUtilization", "InstanceId", instance_id]
          ]
          period = 300
          stat   = "Average"
          region = "eu-west-3"
          title  = "EC2 CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_instance_id]
          ]
          period = 300
          stat   = "Average"
          region = "eu-west-3"
          title  = "RDS Metrics"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.lb_arn_suffix, "TargetGroup", var.target_group_web_arn_suffix],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.lb_arn_suffix, "TargetGroup", var.target_group_streaming_arn_suffix]
          ]
          period = 300
          stat   = "Average"
          region = "eu-west-3"
          title  = "ALB Response Time"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.lb_arn_suffix],
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", var.lb_arn_suffix],
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", var.lb_arn_suffix],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.lb_arn_suffix]
          ]
          period = 300
          stat   = "Sum"
          region = "eu-west-3"
          title  = "ALB Request Metrics"
        }
      }
    ]
  })
}