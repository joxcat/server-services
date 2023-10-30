terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "chat_with_gpt" {
  name = "ghcr.io/cogentapps/chat-with-gpt:release"
}

resource "docker_container" "chat_with_gpt" {
  name = "chat-with-gpt"
  hostname = "chat-with-gpt"
  image = docker_image.chat_with_gpt.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }
  
  volumes {
    host_path = "/var/local/docker/chat-with-gpt/data"
    container_path = "/app/data"
  }

  depends_on = [ docker_image.chat_with_gpt ]
}
