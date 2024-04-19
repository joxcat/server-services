terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "n8n" {
  name = "docker.n8n.io/n8nio/n8n:latest"
}

resource "docker_container" "n8n" {
  name = "n8n"
  hostname = "n8n"
  image = docker_image.n8n.image_id 
  restart = "unless-stopped"
  
  networks_advanced {
    name = var.network
  }

  env = [
    "GENERIC_TIMEZONE=Europe/Paris",
    "N8N_EDITOR_BASE_URL=${var.base_url}",
    "TZ=Europe/Paris"
  ]

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/n8n/data"
    target = "/home/node/.n8n"
  }
}
