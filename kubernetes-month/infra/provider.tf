terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

provider "aws" {
  
  region = local.region
  access_key = var.access_key
  secret_key = var.secret_key

  default_tags {
    tags = {
      Terraform = "true"
      Environment = "dev"  
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "us-east-1"

  vpc_cidr = "10.1.0.0/16"
  vpc_public_cidr = "10.0."

  azs      = slice(data.aws_availability_zones.available.names, 0, 1) 
  #azs      = slice(data.aws_availability_zones.available.names, 0, 3) // To set 3 zones availability

  tags = {
    Example    = local.name
    GithubRepo = "descomplicando-o-kubernetes-on-baremetal"
    GithubOrg  = "drylabs"
  }
}

