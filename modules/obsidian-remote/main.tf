terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "obsidian" {
  name = "obsidian"
  build {
    context = path.module
  }
}

resource "docker_container" "obsidian" {
  name = "obsidian"
  hostname = "obsidian"
  image = docker_image.obsidian.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  env = [
    "CUSTOM_USER=${var.basic_auth_user}",
    "PASSWORD=${var.basic_auth_password}"
  ]

  volumes {
    host_path = var.vaults_folder
    container_path = "/vaults"
  }
  volumes {
    host_path = "/var/local/docker/obsidian/config"
    container_path = "/config"
  }

  depends_on = [ docker_image.obsidian ]
}
