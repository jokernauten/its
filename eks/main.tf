terraform {
#    required_version = ">= 1.2.3"
    backend "s3" {}
}

provider "aws" {
    region = "us-east-1"
}

data "aws_availability_zones" "azs" {
    state = "available"
}

data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
}

resource "aws_security_group" "worker_group_mgmt" {
    name_prefix = "worker_group_mgmt_one"
    vpc_id = module.vpc.vpc_id
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        
        cidr_blocks = [
            "10.0.0.0/8"
        ]
    }
}

resource "aws_eip" "nat" {
  count = 1
  vpc = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = var.vpc_name
  cidr = var.vpc_cidr

  count                     = "${length(data.aws_availability_zones.azs)}"
  azs                       = data.aws_availability_zones.azs.names
  private_subnets           = var.private_subnet
  public_subnets            = var.public_subnet
  enable_nat_gateway        = true
  single_nat_gateway        = true
  one_nat_gateway_per_az    = false
  reuse_nat_ips             = false
  external_nat_ip_ids       = "${aws_eip.nat.*.id}" 
  enable_dns_hostnames      = true

  tags = {
    Name = var.vpc_name
    Terraform = "true"
    Environment = var.env_tag
  }

  public_subnet_tags = {
      Name = var.private_subnet_name
  }

  private_subnet_tags = {
      Name = var.private_subnet_name
  }
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "~> 18.0"
    cluster_name = var.cluster_name
    cluster_version = "1.23"
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    tags = {
        Name = var.cluster_name
    }

    eks_managed_node_group_defaults = {
        disk_size      = var.disk_size
        instance_types = var.instance_type
    }

    eks_managed_node_groups = {
        green = {
            vpc_id = module.vpc.vpc_id
            subnet_ids = module.vpc.private_subnets

            min_size     = var.min_size
            max_size     = var.max_size
            desired_size = var.desired_size
            instance_types = var.instance_type
            capacity_type  = "SPOT"
            
            tags = {
                Environment = var.env_tag
                Terraform   = "true"
            }
        }
    }
    
}

provider "kubernetes" {
    host = data.aws_eks_cluster.cluster.endpoint
    token = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64encode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}