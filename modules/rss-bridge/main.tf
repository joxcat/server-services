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

  mounts {
    type = "bind"
    source = abspath("${path.module}/whitelist.txt")
    target = "/app/whitelist.txt"
    read_only = true
  }

  depends_on = [
    docker_image.rss_bridge
  ]
}
