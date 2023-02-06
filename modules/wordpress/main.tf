terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "wordpress" {
  name = "${var.resource_prefix}_internal_wordpress"
}

resource "docker_image" "wordpress" {
  name = "wordpress:5.7"
}

resource "docker_container" "wordpress_database" {
  name = "${var.resource_prefix}_database"
  hostname = "mysql"
  image = var.mysql_image
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.wordpress.id
  }

  env = [
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=${var.database_password}",
    "MYSQL_RANDOM_ROOT_PASSWORD=1"
  ]

  volumes {
    host_path = "/var/local/docker/${var.resource_prefix}_wordpress/db"
    container_path = "/var/lib/mysql"
  }

  depends_on = [
    docker_network.wordpress
  ]
}

resource "docker_container" "wordpress" {
  name = "${var.resource_prefix}_wordpress"
  hostname = "${var.resource_prefix}_wordpress"
  image = docker_image.wordpress.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.wordpress.id
  }
  networks_advanced {
    name = var.network
  }

  env = [
    "WORDPRESS_DB_HOST=mysql",
    "WORDPRESS_DB_USER=wordpress",
    "WORDPRESS_DB_PASSWORD=${var.database_password}",
    "WORDPRESS_DB_NAME=wordpress"
  ]

  volumes {
    host_path = "/var/local/docker/${var.resource_prefix}_wordpress/data"
    container_path = "/var/www/html"
  }

  depends_on = [
    docker_network.wordpress,
    docker_image.wordpress
  ]
}
