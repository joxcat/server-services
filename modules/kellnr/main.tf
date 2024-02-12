terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "kellnr" {
  name = "ghcr.io/kellnr/kellnr:5.1.2"
}

resource "docker_container" "kellnr" {
  name = "kellnr"
  hostname = "kellnr"
  image = docker_image.kellnr.image_id
  restart = "unless-stopped"

  env = [
    "KELLNR_ORIGIN__HOSTNAME=registry.tracto.pl",
    "KELLNR_ORIGIN__PORT=443",
    "KELLNR_ORIGIN__PROTOCOL=https",
    "KELLNR_DOCS__ENABLED=true"
  ]

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/kellnr/data"
    container_path = "/opt/kdata"
  }

  depends_on = [ docker_image.kellnr ]
}

