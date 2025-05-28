output "lambda_function_name" {
  value = module.lambda.function_name
}

output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}

output "sns_topic_arn" {
  value = module.sns.topic_arn
}