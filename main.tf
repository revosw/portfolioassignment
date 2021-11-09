provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "web" {
  ami = "ami-0bd9c26722573e69b"
  instance_type = "t3.micro"
}
