terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "grocy" {
  name = "lscr.io/linuxserver/grocy:3.3.2"
}

resource "docker_container" "grocy" {
  name = "grocy"
  hostname = "grocy"
  image = docker_image.grocy.image_id
  restart = "unless-stopped"

  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=Europe/Paris",
    "GROCY_CURRENCY=EUR",
    "GROCY_CALENDAR_FIRST_DAY_OF_THE_WEEK=1"
  ]

  volumes {
    host_path = "/var/local/docker/grocy/config"
    container_path = "/config"
  }

  networks_advanced {
    name = var.network
  }

  depends_on = [
    var.network,
    docker_image.grocy
  ]
}


