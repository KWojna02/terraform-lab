output "table_name" {
    value = aws_dynamodb_table.broken_sensors.name
}

output "table_arn" {
    value = aws_dynamodb_table.broken_sensors.arn
}