terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "rss_bridge" {
  name = "rss_bridge"
  build {
    context = "${path.module}/source"
  }
}

resource "docker_container" "rss_bridge" {
  name = "rss-bridge"
  hostname = "rss_bridge"
  image = docker_image.rss_bridge.image_id
  restart = "unless-stopped"
  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = abspath("${path.module}/whitelist.txt")
    container_path = "/app/whitelist.txt"
  }

  depends_on = [
    docker_image.rss_bridge
  ]
}
