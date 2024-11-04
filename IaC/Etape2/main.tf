terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "tcp://localhost:2375"
}

# Créer le réseau Docker avec un nouveau nom
resource "docker_network" "etape2_network" {
  name = "etape2_network"
}

# Conteneur PHP avec FPM
resource "docker_container" "php_container2" {
  name  = "php-fpm2"
  image = "php:7.4-fpm"
  networks_advanced {
    name = docker_network.etape2_network.name
  }
  volumes {
    host_path      = "C:/Users/33660/docker/docker-TPIaC/IaC/Etape2/app"
    container_path = "/var/www/html"
  }
  # Exécuter l'installation de l'extension mysqli au démarrage du conteneur
  command = [
    "/bin/sh",
    "-c",
    "docker-php-ext-install mysqli && php-fpm"
  ]
}

# Conteneur NGINX
resource "docker_container" "nginx_container2" {
  name  = "nginx2"
  image = "nginx:latest"
  networks_advanced {
    name = docker_network.etape2_network.name
  }
  volumes {
    host_path      = "C:/Users/33660/docker/docker-TPIaC/IaC/Etape2/app"
    container_path = "/var/www/html"
  }
  volumes {
    host_path      = "C:/Users/33660/docker/docker-TPIaC/IaC/Etape2/default.conf"
    container_path = "/etc/nginx/conf.d/default.conf"
  }
  ports {
    internal = 80
    external = 8082
  }
}

# Conteneur de base de données (MySQL)
resource "docker_container" "mysql_container" {
  name  = "mysql"
  image = "mysql:5.7"
  env = [
    "MYSQL_ROOT_PASSWORD=root_password",
    "MYSQL_DATABASE=my_database",
    "MYSQL_USER=my_user",
    "MYSQL_PASSWORD=my_password"
  ]
  networks_advanced {
    name = docker_network.etape2_network.name
  }
  ports {
    internal = 3306
    external = 3306
  }
  volumes {
    host_path      = "C:/Users/33660/docker/docker-TPIaC/IaC/Etape2/mysql_data"
    container_path = "/var/lib/mysql"
  }
}
