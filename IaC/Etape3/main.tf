provider "aws" {
  region = "eu-west-3"
}

resource "aws_instance" "nginx_instance" {
  ami           = "ami-0c2ff4ae909115f34"  # AMI Ubuntu 20.04 
  instance_type = "t2.micro"
  key_name      = "ma_cle"  # Le nom de ta clé de paire

  tags = {
    Name = "HTTP-Server"
  }

  security_groups = ["default"]
}

resource "aws_instance" "php_instance" {
  ami           = "ami-0c2ff4ae909115f34"  # La même AMI que précédemment
  instance_type = "t2.micro"
  key_name      = "ma_cle"

  tags = {
    Name = "PHP-Server"
  }

  security_groups = ["default"]
}
