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

  volumes {
    host_path = "/var/local/docker/filestash/config"
    container_path = "/app/data/state"
  }
  volumes {
    host_path = "/var/local/docker/filestash/data"
    container_path = "/data"
  }
  volumes {
    host_path = "/var/local/docker/shareftp/data/data"
    container_path = "/other_data/share"
  }
  volumes {
    host_path = "/var/local/docker/komga/data"
    container_path = "/other_data/komga"
  }

  depends_on = [
    docker_network.filestash,
    docker_image.filestash
  ]
}
