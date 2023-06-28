terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource docker_image "komga" {
  name = "gotson/komga"
}

resource docker_container "komga" {
  name = "komga"
  hostname = "komga"
  image = docker_image.komga.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/komga/data"
    container_path = "/data"
  }

  volumes {
    host_path = "/var/local/docker/komga/config"
    container_path = "/config"
  }

  env = [
    "TZ=Europe/Paris"
  ]

  user = "1000:1000"
}
