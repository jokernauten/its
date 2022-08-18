terraform {
#    required_version = ">= 1.2.3"
    backend "s3" {}
}

provider "aws" {
    region = "us-east-1"
}
