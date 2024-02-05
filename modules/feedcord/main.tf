terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "feedcord" {
  name = "qolors/feedcord:latest"
}

resource "docker_container" "feedcord" {
  name = "feedcord"
  hostname = "feedcord"
  image = docker_image.feedcord.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/feedcord/config"
    container_path = "/app/config"
  }

  depends_on = [
    docker_image.feedcord
  ]
}

