terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Definition
resource "docker_image" "polr" {
  name = "ajanvier/polr:latest"
}
resource "docker_image" "polr_mysql" {
  name = "mysql:8"
}

resource "docker_network" "polr" {
  name = "internal_polr"
}

resource "docker_container" "polr_database" {
  name = "polr_database"
  hostname = "polr_database"
  image = docker_image.polr_mysql.image_id 
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.polr.id
  }

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/polr/data"
    target = "/var/lib/mysql"
  }

  env = [
    "MYSQL_DATABASE=polr", 
    "MYSQL_USER=polr",
    "MYSQL_PASSWORD=${var.mysql_password}",
    "MYSQL_RANDOM_ROOT_PASSWORD=yes"
  ]

  depends_on = [
    docker_network.polr,
  ]
}

resource "docker_container" "polr_frontend" {
  name = "polr"
  hostname = "polr"
  image = docker_image.polr.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }
  networks_advanced {
    name = docker_network.polr.id
  }

  env = [
    "DB_HOST=polr_database",
    "DB_PASSWORD=${var.mysql_password}",
    "APP_NAME=${var.app_name}",
    "APP_ADDRESS=${var.app_address}",
    "ADMIN_USERNAME=${var.default_admin_username}",
    "ADMIN_PASSWORD=${var.default_admin_password}",
    "SETTING_SHORTEN_PERMISSION=true"
  ]

  depends_on = [
    docker_network.polr,
    docker_container.polr_database
  ]
}
