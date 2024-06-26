terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "internal_paperless" {
  name = "internal_paperless"
}

resource "docker_image" "paperless" {
  name = "ghcr.io/paperless-ngx/paperless-ngx:2.1.3"
}
resource "docker_image" "paperless_redis" {
  name = "redis:7"
}

resource "docker_container" "paperless_redis" {
  name = "paperless_redis"
  hostname = "paperless_redis"
  image = docker_image.paperless_redis.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.internal_paperless.id
  }

  depends_on = [ docker_network.internal_paperless ]
}

resource "docker_container" "paperless" {
  name = "paperless"
  hostname = "paperless"
  image = docker_image.paperless.image_id
  restart = "unless-stopped"

  env = [
    "PAPERLESS_URL=https://paper.johan.moe",
    "PAPERLESS_REDIS=redis://paperless_redis:6379",
    "PAPERLESS_OCR_USER_ARGS='{\"continue_on_soft_render_error\": true}'",
    "DEBUG=false"
  ]

  networks_advanced {
    name = var.network
  }
  networks_advanced {
    name = docker_network.internal_paperless.id
  }

  volumes {
    host_path = "/var/local/docker/paperless/data/database"
    container_path = "/usr/src/paperless/data"
  }
  volumes {
    host_path = "/var/local/docker/paperless/data/media"
    container_path = "/usr/src/paperless/media"
  }
  volumes {
    host_path = "/var/local/docker/paperless/export"
    container_path = "/usr/src/paperless/export"
  }
  volumes {
    host_path = "/var/local/docker/paperless/consume"
    container_path = "/usr/src/paperless/consume"
  }

  depends_on = [
    docker_image.paperless,
    docker_network.internal_paperless
  ]
}
