terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3" 
}

# Clé SSH pour accéder aux instances
variable "ssh_key_name" {
  type    = string
  default = "ma_cle"
}

# ID de l'AMI 
variable "ami_id" {
  type    = string
  default = "ami-0c2ff4ae909115f34"
}

# Instance pour le serveur NGINX
resource "aws_instance" "nginx" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.ssh_key_name

  # Script d'initialisation pour NGINX
  user_data = <<-EOF
    #!/bin/bash
    # Mettre à jour le système et installer NGINX et PHP-FPM
    sudo apt-get update -y
    sudo apt-get install -y nginx php-fpm

    # Créer le dossier racine pour NGINX et ajouter un fichier de test
    sudo mkdir -p /home/ubuntu/IaC/Etape4/app
    echo "<?php phpinfo(); ?>" | sudo tee /home/ubuntu/IaC/Etape4/app/index.php

    # Configurer NGINX pour utiliser le répertoire /home/ubuntu/IaC/Etape4/app comme racine
    sudo bash -c 'cat > /etc/nginx/sites-available/default << "END"
    server {
      listen 80;
      server_name localhost;

      root /home/ubuntu/IaC/Etape4/app;
      index index.php index.html;

      location / {
          try_files $uri $uri/ =404;
      }

      location ~ \.php$ {
          fastcgi_pass unix:/run/php/php8.3-fpm.sock;
          fastcgi_index index.php;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          include fastcgi_params;
      }
    }
    END'

    # Redémarrer NGINX
    sudo systemctl restart nginx
  EOF

  tags = {
    Name = "nginx-server"
  }
}

# Instance pour le serveur PHP-FPM
resource "aws_instance" "php" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.ssh_key_name

  # Script d'initialisation pour PHP-FPM
  user_data = <<-EOF
    #!/bin/bash
    # Mettre à jour le système et installer PHP-FPM
    sudo apt-get update -y
    sudo apt-get install -y php-fpm

    # Démarrer PHP-FPM
    sudo systemctl enable php8.3-fpm
    sudo systemctl start php8.3-fpm
  EOF

  tags = {
    Name = "php-server"
  }
}

# Instance pour le serveur MySQL
resource "aws_instance" "mysql" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.ssh_key_name

  # Script d'initialisation pour MySQL
  user_data = <<-EOF
    #!/bin/bash
    # Mettre à jour le système et installer MySQL
    sudo apt-get update -y
    sudo apt-get install -y mysql-server

    # Configurer MySQL (exemple de base)
    sudo mysql -e "CREATE DATABASE my_database;"
    sudo mysql -e "CREATE USER 'my_user'@'%' IDENTIFIED BY 'my_password';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON my_database.* TO 'my_user'@'%';"
    sudo mysql -e "FLUSH PRIVILEGES;"
  EOF

  tags = {
    Name = "mysql-server"
  }
}

# Sorties des adresses IP publiques
output "nginx_public_ip" {
  value = aws_instance.nginx.public_ip
}

output "php_public_ip" {
  value = aws_instance.php.public_ip
}

output "mysql_public_ip" {
  value = aws_instance.mysql.public_ip
}
