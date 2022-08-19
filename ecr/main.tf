terraform {
    backend "s3" {}
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_ecr_repository" "its-ecr" {
  name = var.ecr_name
}