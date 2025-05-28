data "archive_file" "lambda_zip" {
    type = "zip"
    source_file = var.file_path
    output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "sensor_classifier" {
    filename = data.archive_file.lambda_zip.output_path
    function_name = var.function_name
    role = var.lambda_role_arn
    handler = "sensor_classifier.handler"
    runtime = "nodejs22.x"
    timeout = 30

    source_code_hash = data.archive_file.lambda_zip.output_base64sha256

    environment {
      variables = {
        TABLE_NAME = var.dynamodb_table_name
        SNS_TOPIC_ARN = var.sns_topic_arn
      }
    }

    tags = {
        Name = var.function_name
    }

}