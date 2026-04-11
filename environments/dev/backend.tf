terraform {
  backend "s3" {
    bucket         = "secure-kafka-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "secure-kafka-tfstate-lock"
  }
}
