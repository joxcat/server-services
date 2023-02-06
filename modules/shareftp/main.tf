terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "shareftp" {
  name = "bytemark/webdav"
}

resource "docker_container" "shareftp" {
  name = "shareftp"
  hostname = "shareftp"
  image = docker_image.shareftp.image_id
  restart = "unless-stopped"
  
  networks_advanced {
    name = var.network
  }

  env = [
    "AUTH_TYPE=Basic",
    "USERNAME=${var.username}",
    "PASSWORD=${var.password}",
    "SERVER_NAMES=${var.host}"
  ]

  volumes {
    host_path = "/var/local/docker/shareftp/data"
    container_path = "/var/lib/dav"
  }

  depends_on = [
    docker_image.shareftp
  ]
}
