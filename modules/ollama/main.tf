terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "ollama_webui" {
  name = "ghcr.io/ollama-webui/ollama-webui:main"
}

resource "docker_image" "ollama" {
  name = "ollama/ollama:latest"
}

resource "docker_network" "internal_ollama" {
  name = "internal_ollama"
}

resource "docker_container" "ollama" {
  name = "ollama"
  hostname = "ollama"
  image = docker_image.ollama.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.internal_ollama.id
  }

  volumes {
    host_path  = "/var/local/docker/ollama/ollama-server"
    container_path = "/root/.ollama"
  }

  depends_on = [
    docker_image.ollama
  ]
}

resource "docker_container" "ollama_webui" {
  name = "ollama_webui"
  hostname = "ollama_webui"
  image = docker_image.ollama_webui.image_id
  restart = "unless-stopped"

  env = [ "OLLAMA_API_BASE_URL=http://ollama:11434/api" ]

  networks_advanced {
    name = var.network
  }
  networks_advanced {
    name = docker_network.internal_ollama.id
  }

  volumes {
    host_path = "/var/local/docker/ollama/data"
    container_path = "/app/backend/data"
  }

  depends_on = [
    docker_image.ollama_webui,
    docker_container.ollama
  ]
}

