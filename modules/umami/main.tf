terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "umami" {
  name = "ghcr.io/umami-software/umami:postgresql-latest"
}
resource "docker_image" "umami_postgres" {
  name = "postgres:15-alpine"
}

resource "docker_network" "umami" {
  name = "internal_umami"
}

resource "docker_volume" "umami_data" {
  name = "umami_data"
  driver = "rclone:latest"
  
  driver_opts = {
    path = "${var.sftp_path}/umami/data"
    type = "sftp"
    sftp-host = var.sftp_host
    sftp-port = var.sftp_port
    sftp-user = var.sftp_user
    sftp-pass = var.sftp_password
    allow-other = "true"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "docker_container" "umami_database" {
  name = "umami_database"
  hostname = "umami_database"
  image = docker_image.umami_postgres.image_id
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.umami.id
  }

  volumes {
    volume_name = docker_volume.umami_data.name
    container_path = "/var/lib/postgresql/data"
  }

  env = [
    "POSTGRES_DB=umami", 
    "POSTGRES_USER=umami",
    "POSTGRES_PASSWORD=${var.postgres_password}",
  ]

  depends_on = [
    docker_network.umami,
  ]
}

resource "docker_container" "umami" {
  name = "umami"
  hostname = "umami"
  image = docker_image.umami.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }
  networks_advanced {
    name = docker_network.umami.id
  }

  env = [
    "DATABASE_URL=postgresql://umami:${var.postgres_password}@umami_database:5432/umami",
    "DATABASE_TYPE=postgresql",
    "APP_SECRET=${var.app_secret}",
  ]

  depends_on = [
    docker_network.umami,
    docker_container.umami_database
  ]
}
