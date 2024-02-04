terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "lobe_chat" {
  name = "lobehub/lobe-chat:v0.122.6"
}

resource "docker_container" "lobe_chat" {
  name = "lobe_chat"
  hostname = "lobe_chat"
  image = docker_image.lobe_chat.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  depends_on = [
    docker_image.lobe_chat
  ]
}
