terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "ghost" {
  name = "internal_ghost"
}

resource "docker_image" "ghost" {
  name = "ghost:5-alpine"
}

resource "docker_container" "ghost_database" {
  name = "ghost_database"
  hostname = "ghost_database"
  image = var.mysql_image
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.ghost.id
  }

  env = ["MYSQL_ROOT_PASSWORD=${var.mysql_password}"]

  volumes {
    host_path = "/var/local/docker/ghost/data"
    container_path = "/var/lib/mysql"
  }

  depends_on = [
    docker_network.ghost
  ]
}

resource "docker_container" "ghost" {
  name = "ghost"
  hostname = "ghost"
  image = docker_image.ghost.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.ghost.id
  }
  networks_advanced {
    name = var.network
  }

  env = [
    "database__client=mysql",
    "database__connection__host=ghost_database",
    "database__connection__user=root",
    "database__connection__password=${var.mysql_password}",
    "database__connection__database=ghost",
    "url=${var.public_url}",
    "privacy__useGravatar=false",
    "privacy__useRpcPing=false",
    "privacy__useStructuredData=false",
    "privacy__useUpdateCheck=false",
    "mail__transport=SMTP",
    "mail__from=${var.smtp_from}",
    "mail__options__host=${var.smtp_host}",
    "mail__options__port=${var.smtp_port}",
    "mail__options__auth__user=${var.smtp_user}",
    "mail__options__auth__pass=${var.smtp_password}"
  ]

  volumes {
    host_path = "/var/local/docker/ghost/content"
    container_path = "/var/lib/ghost/content"
  }

  depends_on = [
    docker_network.ghost,
    docker_image.ghost
  ]
}
