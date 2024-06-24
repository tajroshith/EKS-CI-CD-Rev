terraform {
  required_version = "~>1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.53.0"
    }
  }
  backend "s3" {
    bucket         = "module-state-s3"
    region         = "ap-south-1"
    dynamodb_table = "tf-state-locking"
  }
}