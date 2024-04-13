terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "tailscale" {
  name = "ghcr.io/tailscale/tailscale:latest"
}

resource "docker_volume" "tailscale" {}

resource "docker_container" "tailscale" {
  name = "tailscale"
  hostname = "tailscale"
  image = docker_image.tailscale.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/tailscale/data"
    target = "/var/lib/postgresql/data"
  }

  env = [
    "TS_STATE_DIR=/var/lib/tailscale",
    "TS_AUTHKEY=${var.auth_key}",
  ]

  depends_on = [
    docker_image.tailscale
  ]
}
