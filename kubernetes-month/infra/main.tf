module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "drylabs-vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, 2)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, 4)]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


/* 
# Create key pair
aws ec2 create-key-pair \
    --key-name deployer-key \
    --key-type rsa \
    --key-format pem \
    --query "KeyMaterial" \
    --output text > deployer-key.pem
*/

data "aws_key_pair" "deployer" {
  key_name           = "deployer-key"
  include_public_key = true
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  count = 1
  name  = "${local.name}-k8s-${count.index}"

  instance_type = "t2.medium"
  key_name      = data.aws_key_pair.deployer.key_name
  monitoring    = false

  vpc_security_group_ids      = [module.vpc.default_security_group_id]
  subnet_id                   = module.vpc.private_subnets[0]
  associate_public_ip_address = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}