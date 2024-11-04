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

# Créer le réseau Docker
resource "docker_network" "my_network" {
  name = "my_network"
}

# Conteneur PHP avec FPM
resource "docker_container" "php_container" {
  name  = "php-fpm"
  image = "php:7.4-fpm"
  networks_advanced {
    name = docker_network.my_network.name
  }
  volumes {
    host_path      = "C:/Users/33660/docker/docker-TPIaC/IaC/Etape1/app"
    container_path = "/var/www/html"
  }
}

# Conteneur NGINX
resource "docker_container" "nginx_container" {
  name  = "nginx"
  image = "nginx:latest"
  networks_advanced {
    name = docker_network.my_network.name
  }
  volumes {
    host_path      = "C:/Users/33660/docker/docker-TPIaC/IaC/Etape1/app"
    container_path = "/var/www/html"
  }
  volumes {
    host_path      = "C:/Users/33660/docker/docker-TPIaC/IaC/Etape1/default.conf"
    container_path = "/etc/nginx/conf.d/default.conf"
  }
  ports {
    internal = 80
    external = 8080
  }
}
