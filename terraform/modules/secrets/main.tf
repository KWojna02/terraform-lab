resource "aws_ssm_parameter" "notification_email" {
  name  = "/${var.project_name}/notification-email"
  type  = "SecureString"
  value = var.notification_email

  tags = {
    Name = var.project_name
  }
}

