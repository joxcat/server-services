terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "filestash" {
  name = "filestash_internal"
}

resource "docker_image" "onlyoffice" {
  name = "onlyoffice/documentserver"
}
resource "docker_image" "filestash" {
  name = "machines/filestash"
}

resource "docker_container" "onlyoffice" {
  name = "onlyoffice"
  hostname = "onlyoffice"
  image = docker_image.onlyoffice.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.filestash.id
  }

  depends_on = [
    docker_network.filestash,
    docker_image.onlyoffice
  ]
}

resource "docker_container" "filestash" {
  name = "filestash"
  hostname = "filestash"
  image = docker_image.filestash.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.filestash.id
  }
  networks_advanced {
    name = var.network
  }

  env = [
    "APPLICATION_URL=",
    "ONLYOFFICE_URL=http://onlyoffice",
    "CONFIG_SECRET=${var.config_secret}"
  ]

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/filestash/config"
    target = "/app/data/state"
  }
  mounts {
    type = "bind"
    source = abspath("${path.module}/local_data")
    target = "/data"
  }

  depends_on = [
    docker_network.filestash,
    docker_image.filestash
  ]
}
