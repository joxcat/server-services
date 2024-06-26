terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "homepage" {
  name = "ghcr.io/gethomepage/homepage:latest"
}

resource "docker_container" "homepage" {
  name = "homepage"
  hostname = "homepage"
  image = docker_image.homepage.image_id 
  restart = "unless-stopped"
  
  networks_advanced {
    name = var.network
  }

  env = [
    "PUID=1000",
    "PGID=1000",
  ]

  mounts {
    type = "bind"
    source = abspath("${path.module}/icons")
    target = "/app/public/icons"
  }
  mounts {
    type = "bind"
    source = abspath("${path.module}/images")
    target = "/app/public/images"
  }
  mounts {
    type = "bind"
    source = "/var/lib/docker-data/homepage/config"
    target = "/app/config"
  }
  mounts {
    type = "bind"
    source = "/var/run/docker.sock"
    target = "/var/run/docker.sock"
  }

  group_add = [var.docker_group_id]
}