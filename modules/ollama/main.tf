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

resource "docker_volume" "ollama_data" {
  name = "ollama_data"
  driver = "rclone:latest"
  
  driver_opts = {
    path = "${var.sftp_path}/ollama/data"
    type = "sftp"
    sftp-host = var.sftp_host
    sftp-port = var.sftp_port
    sftp-user = var.sftp_user
    sftp-pass = var.sftp_password
    allow-other = "true"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "docker_container" "ollama" {
  name = "ollama"
  hostname = "ollama"
  image = docker_image.ollama.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.internal_ollama.id
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
    volume_name = docker_volume.ollama_data.name
    container_path = "/app/backend/data"
  }

  depends_on = [
    docker_image.ollama_webui,
    docker_container.ollama
  ]
}

