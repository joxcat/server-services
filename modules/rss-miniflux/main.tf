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

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/rss-miniflux/data"
    target = "/var/lib/postgresql/data"
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
    docker_image.miniflux,
    docker_container.miniflux_database
  ]
}
