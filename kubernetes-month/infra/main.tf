# Create RSA key of size 4096 bits
resource "tls_private_key" "tf_ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create local file
resource "local_file" "tf_ec2_key" {
  content  = tls_private_key.tf_ec2_key.private_key_pem
  filename = "${path.module}/tf_ec2_key.pem"
}

# Create AWS key pair
resource "aws_key_pair" "tf_ec2_key" {
  key_name   = "tf_ec2_key"
  public_key = tls_private_key.tf_ec2_key.public_key_openssh
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  count = 1
  name  = "${local.name}-k8s-${count.index}"

  instance_type = "t2.medium"
  key_name      = aws_key_pair.tf_ec2_key.key_name
  monitoring    = false

  vpc_security_group_ids      = [module.vpc.default_security_group_id]
  subnet_id                   = module.vpc.private_subnets[0]
  associate_public_ip_address = true


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}