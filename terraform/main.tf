terraform {
  backend "s3" {
    bucket = "sensor-monitoring-tfstate-251be28f"
    key = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "sensor-monitoring-terraform-locks"
    encrypt = true
  }
}

provider "aws" {
    region = "us-east-1"
}

provider "archive" {}

data "aws_iam_role" "main_role"{
    name = "LabRole"
}

module "dynamodb" {
    source = "./modules/dynamodb"

    table_name = "${var.project_name}-broken-sensors"
}

module "sns" {
    source = "./modules/sns"

    topic_name = "${var.project_name}-alerts"
    notification_email = var.notification_email
}

module "lambda"{
    source = "./modules/lambda"

    function_name = "${var.project_name}-lambda"
    lambda_role_arn = data.aws_iam_role.main_role.arn
    file_path = "${path.module}/../src/sensor_classifier.mjs"
    dynamodb_table_name = module.dynamodb.table_name
    sns_topic_arn = module.sns.topic_arn
}