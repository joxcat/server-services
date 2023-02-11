terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "writefreely" {
  name = "internal_writefreely"
}

resource "docker_image" "writefreely" {
  name = "writeas/writefreely:latest"
}

resource "docker_container" "writefreely_database" {
  name = "writefreely_database"
  hostname = "writefreely-db"
  image = var.mariadb_image
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.writefreely.id
  }

  env = [
    "MYSQL_DATABASE=writefreely",
    "MYSQL_ROOT_PASSWORD=${var.mariadb_password}",
  ]

  volumes {
    host_path = "/var/local/docker/writefreely/data"
    container_path = "/var/lib/mysql"
  }

  depends_on = [
    docker_network.writefreely
  ]
}

resource "docker_container" "writefreely" {
  name = "writefreely"
  hostname = "writefreely"
  image = docker_image.writefreely.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.writefreely.id
  }
  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/writefreely/keys"
    container_path = "/go/keys"
  }
  volumes {
    host_path = "/var/local/docker/writefreely/config.ini"
    container_path = "/go/config.ini"
  }

  depends_on = [
    docker_network.writefreely,
    docker_image.writefreely
  ]
}
