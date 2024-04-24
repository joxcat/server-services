terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "coder" {
  name = "internal_coder"
}

resource "docker_image" "coder" {
  name = "ghcr.io/coder/coder:v2.10.2"
}
resource "docker_image" "coder_postgres" {
  name = "postgres:14"
}

resource "docker_container" "coder_database" {
  name = "coder_database"
  hostname = "database"
  image = docker_image.coder_postgres.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.coder.id
  }

  env = [
    "POSTGRES_USER=coder",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=coder"
  ]

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/coder/data"
    target = "/var/lib/postgresql/data"
  }

  healthcheck {
    test = ["CMD-SHELL", "pg_isready -U coder -d ${var.postgres_password}"]
    interval = "5s"
    timeout = "5s"
    retries = 5
  }

  depends_on = [
    docker_network.coder
  ]
}

resource "docker_container" "coder" {
  name = "coder"
  hostname = "coder"
  image = docker_image.coder.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.coder.id
  }
  networks_advanced {
    name = var.network
  }
  networks_advanced {
    name = "bridge"
  }

  env = [
    "CODER_PG_CONNECTION_URL=postgresql://coder:${var.postgres_password}@database/coder?sslmode=disable",
    "CODER_HTTP_ADDRESS=0.0.0.0:7080",
    "CODER_ACCESS_URL=${var.access_url}",
    "CODER_WILDCARD_ACCESS_URL=${var.wildcard_url}",
    // https://github.com/coder/coder/issues/9550
    // "CODER_DERP_SERVER_STUN_ADDRESSES=disable",
    // "CODER_BLOCK_DIRECT=true",
    // "CODER_DERP_FORCE_WEBSOCKETS=true",
    // "CODER_DERP_CONFIG_URL=https://controlplane.tailscale.com/derpmap/default",
    // "CODER_DERP_SERVER_ENABLE=false"
  ]

  mounts {
    type = "bind"
    source = "/var/run/docker.sock"
    target = "/var/run/docker.sock"
  }

  group_add = [var.docker_group_id]

  depends_on = [
    docker_network.coder,
    docker_image.coder
  ]
}
