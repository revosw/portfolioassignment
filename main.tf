terraform {
  backend "s3" {
    bucket = "terraform-state-emofc"
    key    = "global/s3/terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "terraform-locks-emofc"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "web" {
  # Which virtual machine image this VM should be based on
  ami = "ami-0bd9c26722573e69b"
  # How much hardware resources does this instance need
  instance_type = "t3.micro"
  # What commands should be executed when the VM boots
  user_data = file("install.sh")
  # The ssh key pair to apply to this virtual machine
  key_name = "terraform-emofc"
  # Required for network setup
  security_groups = ["terraform-sg-emofc"]
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform-emofc"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0eZppw2NRHMeH598Tq141MIgoVw4T/8/Bma8/7Ukgysh6zAhqzpDM0SZ1deKd+f5JrbeXkiADCTJSv+KoixlDFqzLuHHCy0XppClfFnncSwNCoVNQ1gn9m0ZymzA9qOqyETtuc804yUbLpcrcqXEUOYcshRhl5TfM0Y6xP7ClakGU3XmvdrJD3XTSVCz/+3gmmqy8irC5j4MRDxeq0iYqUiv6tPo0z85DZQwpIAGCVh+NcfP5o9YxdU3vY89NXHmIspOfnSBjHnT+PrwLbwwScy0M1IP30pUrExietDCAcBQygJ9F4rZbIRHVMu64z3FUHkFpAfgtjmjbfj7p4PnV"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-emofc"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-emofc"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_security_group" "terraform-sg" {
  name = "terraform-sg-emofc"
  egress = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 0
      protocol    = "-1"
      self        = false
      to_port     = 0
    }
  ]
  ingress = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 22
      protocol    = "tcp"
      self        = false
      to_port     = 22
    }
  ]
}


