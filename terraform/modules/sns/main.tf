data "aws_ssm_parameter" "notification_email" {
  name = var.notification_email_parameter
  with_decryption = true
}

resource "aws_sns_topic" "sensor_alerts" {
    name = var.topic_name

    tags = {
      Name = var.topic_name
    }
}

resource "aws_sns_topic_subscription" "email_notification" {
    topic_arn = aws_sns_topic.sensor_alerts.arn
    protocol = "email"
    endpoint = data.aws_ssm_parameter.notification_email.value
}