provider "aws" {
    region = "us-east-1"
}

resource "random_id" "bucket_suffix"{
    byte_length = 4
}

resource "aws_s3_bucket" "terraform_state"{
    bucket = "sensor-monitoring-tfstate-${random_id.bucket_suffix.hex}"
}

resource "aws_dynamodb_table" "terraform_locks" {
    name = "sensor-monitoring-terraform-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }
}