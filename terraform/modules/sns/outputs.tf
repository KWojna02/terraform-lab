output "topic_name" {
  value = aws_sns_topic.sensor_alerts.name
}

output "topic_arn" {
  value = aws_sns_topic.sensor_alerts.arn
}