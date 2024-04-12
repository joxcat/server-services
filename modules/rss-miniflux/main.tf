terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "miniflux" {
  name = "internal_miniflux"
}

resource "docker_image" "miniflux" {
  name = "miniflux/miniflux:2.0.50"
}
resource "docker_image" "miniflux_postgres" {
  name = "postgres:14"
}

resource "docker_volume" "miniflux_data" {
  name = "miniflux_data"
  driver = "rclone:latest"
  
  driver_opts = {
    path = "${var.sftp_path}/rss_miniflux/data"
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

resource "docker_container" "miniflux_database" {
  name = "miniflux_database"
  hostname = "miniflux_database"
  image = docker_image.miniflux_postgres.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.miniflux.id
  }

  env = [
    "POSTGRES_USER=miniflux",
    "POSTGRES_PASSWORD=${var.database_password}"
  ]

  volumes {
    volume_name = docker_volume.miniflux_data.name
    container_path = "/var/lib/postgresql/data"
  }

  healthcheck {
    test = ["CMD", "pg_isready", "-U", "miniflux"]
    interval = "10s"
    start_period = "30s"
  }

  depends_on = [
    docker_network.miniflux
  ]
}

resource "docker_container" "miniflux" {
  name = "miniflux"
  hostname = "miniflux"
  image = docker_image.miniflux.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.miniflux.id
  }

  networks_advanced {
    name = var.network
  }

  env = [
    "DATABASE_URL=postgres://miniflux:${var.database_password}@miniflux_database/miniflux?sslmode=disable",
    "RUN_MIGRATIONS=1"
  ]

  depends_on = [
    docker_network.miniflux,
    docker_image.miniflux
  ]
}
