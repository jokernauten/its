terraform {
    backend "s3" {}
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_efs_file_system" "efs" {
   creation_token = "efs"
   performance_mode = var.performance_mode
   throughput_mode = var.throughput_mode
   encrypted = "true"
 tags = {
     Name = "its-efs"
   }
 }