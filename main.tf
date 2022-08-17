terraform {
    required_version = ">= 1.2.3"
}

provider "aws" {
    region = var.region
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

  name = "grid-vpc"
  cidr = "10.0.0.0/16"

  azs = data.aws_availability_zones.azs.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  reuse_nat_ips       = true
  external_nat_ip_ids = "${aws_eip.nat.*.id}" 
  enable_dns_hostnames = true

  tags = {
    Name = "grid-vpc"
    Terraform = "true"
    Environment = "dev"
  }

  public_subnet_tags = {
      Name = "grid-private-subnet"
  }

  private_subnet_tags = {
      Name = "grid-public-subnet"
  }
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "~> 18.0"
    cluster_name = var.cluster_name
    cluster_version = "1.22"
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    tags = {
        Name = "eks-cluster"
    }

    eks_managed_node_group_defaults = {
        disk_size      = 50
        instance_types = ["t2.micro"]
    }

    eks_managed_node_groups = {
        green = {
            vpc_id = module.vpc.vpc_id
            subnet_ids = module.vpc.private_subnets

            min_size     = 2
            max_size     = 10
            desired_size = 2
            instance_types = ["t2.medium"]
            capacity_type  = "SPOT"
            
            tags = {
                Environment = "dev"
                Terraform   = "true"
            }
        }
    }

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::489194400276:user/developer-user1"
      username = "developer-user1"
      groups   = ["system:masters"]
    },
  ]
    
}

provider "kubernetes" {
    host = data.aws_eks_cluster.cluster.endpoint
    token = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64encode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}