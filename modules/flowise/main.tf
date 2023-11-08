terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "flowise" {
  name = "flowiseai/flowise:1.3.9"
}

resource "docker_container" "flowise" {
  name = "flowise"
  hostname = "flowise"
  image = docker_image.flowise.image_id
  restart = "unless-stopped"

  command = [ "/bin/sh", "-c", "sleep 3; flowise start" ]

  env = [
    "PORT=7860",
    "DATABASE_PATH=/root/.flowise",
    "APIKEY_PATH=/root/.flowise",
    "SECRETKEY_PATH=/root/.flowise",
    "LOG_PATH=/root/.flowise/logs",
    "FLOWISE_USERNAME=${var.flowise_username}",
    "FLOWISE_PASSWORD=${var.flowise_password}"
  ]

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/flowise/data"
    container_path = "/root/.flowise"
  }

  depends_on = [ docker_image.flowise ]
}
