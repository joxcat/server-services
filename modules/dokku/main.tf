terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "dind" {
  name = "docker:dind"
}
resource "docker_image" "dokku" {
  name = "dokku/dokku:0.34.4"
}

resource "docker_network" "internal_dokku" {
  name = "internal_dokku"
}

resource "docker_container" "dokku_dind" {
  name = "dokku_dind"
  hostname = "dokku_dind"
  image = docker_image.dind.image_id
  restart = "unless-stopped"
  privileged = true
  command = [ "dockerd", "-H", "tcp://0.0.0.0:2375", "--tls=false" ]

  networks_advanced {
    name = docker_network.internal_dokku.id
  }

  depends_on = [
    docker_image.dind,
    docker_network.internal_dokku
  ]
}

resource "docker_container" "dokku" {
  name = "dokku"
  hostname = "dokku"
  image = docker_image.dokku.image_id
  restart = "unless-stopped"

  env = [
    "DOCKER_HOST=tcp://dokku_dind:2375",
    "DOKKU_HOSTNAME=fly.johan.moe",
    "DOKKU_HOST_ROOT=/var/lib/docker-data/dokku/home/dokku",
    "DOKKU_LIB_HOST_ROOT=/var/lib/docker-data/dokku/var/lib/dokku"
  ]

  ports {
    internal = 22
    external = 22
  }

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/dokku"
    target = "/mnt/dokku"
  }

  networks_advanced {
    name = docker_network.internal_dokku.id
  }
  networks_advanced {
    name = var.network
  }

  depends_on = [
    docker_network.internal_dokku,
    docker_container.dokku
  ]
}

