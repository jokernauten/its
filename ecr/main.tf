terraform {
    backend "s3" {}
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_ecr_repository" "its-ecr" {
  name = var.ecr_name
}

resource "aws_ecr_repository_policy" "its-ecr-policy" {
  repository = aws_ecr_repository.its-ecr.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:CompleteLayerUpload"
                "ecr:PutImage"
            ]
        }
    ]
}
EOF
}