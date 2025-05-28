resource "aws_dynamodb_table" "broken_sensors" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "sensor_id"

  attribute {
    name = "sensor_id"
    type = "S"
  }

  tags = {
    Name = var.table_name
  }
}

