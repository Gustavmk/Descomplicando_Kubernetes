

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "drylabs-vpc"
  cidr = local.vpc_cidr

  #azs             = ["us-east-1a", "us-east-1b", "us-east-1c"] // Availability zones
  azs             = local.azs
  #private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, 2)]

  #public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, 4)]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}



# module "ec2_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"

#   name = "spot-instance"

#   create_spot_instance = true
#   spot_price           = "0.60"
#   spot_type            = "persistent"

#   instance_type          = "t2.micro"
#   key_name               = "user1"
#   monitoring             = false

#   vpc_security_group_ids = ["sg-12345678"]
#   subnet_id              = "subnet-eddcdzz4"

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }


# }