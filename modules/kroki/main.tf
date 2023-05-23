terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "kroki" {
  name = "yuzutech/kroki:latest"
}

resource "docker_container" "kroki" {
  name = "kroki"
  hostname = "kroki"
  image = docker_image.kroki.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  env = [
    "KROKI_SAFE_MODE=safe"
  ]

  depends_on = [
    docker_image.kroki
  ]
}
