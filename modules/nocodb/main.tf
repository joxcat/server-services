terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "nocodb" {
  name = "nocodb/nocodb:latest"
}

resource "docker_container" "nocodb" {
  name = "nocodb"
  hostname = "nocodb"
  image = docker_image.nocodb.image_id 
  restart = "unless-stopped"
  
  networks_advanced {
    name = var.network
  }

  env = [
    "NC_DISABLE_TELE=true",
    "NC_DB=sqlite:///usr/app/data/nocodb.db"
  ]

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/nocodb/data"
    target = "/usr/app/data"
  }
}