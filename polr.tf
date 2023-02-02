# Variables
variable "polr_mysql_password" {
  description = "Polr's MySQL password"
  type = string
}
variable "polr_app_name" {
  description = "Polr's displayed name"
  type = string
}
variable "polr_app_address" {
  description = "Polr's exposed host"
  type = string
}
variable "polr_default_admin_username" {
  description = "Polr's default admin username"
  type = string
}
variable "polr_default_admin_password" {
  description = "Polr's default admin password"
  type = string
}

# Definition
resource "docker_image" "polr" {
  name = "ajanvier/polr:latest"
}

resource "docker_network" "polr" {
  name = "internal_polr"
}

resource "docker_container" "polr_database" {
  name = "polr_database"
  hostname = "polr_database"
  image = docker_image.mysql_8.image_id
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.polr.id
  }

  volumes {
    host_path = "/var/local/docker/polr/data"
    container_path = "/var/lib/mysql"
  }

  env = [
    "MYSQL_DATABASE=polr", 
    "MYSQL_USER=polr",
    "MYSQL_PASSWORD=${var.polr_mysql_password}",
    "MYSQL_RANDOM_ROOT_PASSWORD=yes"
  ]
}

resource "docker_container" "polr_frontend" {
  name = "polr"
  image = docker_image.polr.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.polr.id
  }
  networks_advanced {
    name = docker_network.internal_proxy.id
  }

  env = [
    "DB_HOST=polr_database",
    "DB_PASSWORD=${var.polr_mysql_password}",
    "APP_NAME=${var.polr_app_name}",
    "APP_ADDRESS=${var.polr_app_address}",
    "ADMIN_USERNAME=${var.polr_default_admin_username}",
    "ADMIN_PASSWORD=${var.polr_default_admin_password}",
    "SETTING_SHORTEN_PERMISSION=true"
  ]
}
