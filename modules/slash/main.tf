terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "slash" {
  name = "yourselfhosted/slash:latest"
}

resource "docker_container" "slash" {
  name = "slash"
  hostname = "slash"
  image = docker_image.slash.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/slash"
    container_path = "/var/opt/slash"
  }

  depends_on = [
    docker_image.slash
  ]
}
