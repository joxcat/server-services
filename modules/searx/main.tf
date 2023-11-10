terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "searx" {
  name = "internal_searx"
}

resource "docker_image" "searx" {
  name = "searx"
  build {
    context = "${path.module}/source"
  }
}

resource "docker_container" "redis" {
  name = "searx_redis"
  hostname = "redis"
  image = var.redis_image
  restart = "unless-stopped"
  command = ["redis-server", "--save", "\"\"", "--appendonly", "no"]

  networks_advanced {
    name = docker_network.searx.id
  }

  tmpfs = {
    "/var/lib/redis" = ""
  }

  capabilities {
    drop = ["ALL"]
    add = ["SETGID", "SETUID", "DAC_OVERRIDE"]
  }

  depends_on = [
    docker_network.searx
  ]
}

resource "docker_container" "searx" {
  name = "searx"
  hostname = "searxng"
  image = docker_image.searx.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.searx.id
  }
  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = abspath("${path.module}/source/data")
    container_path = "/etc/searxng"
  }
  volumes {
    host_path = abspath("${path.module}/source/searx/engines")
    container_path = "/usr/local/searxng/searx/engines"
  }
  volumes {
    host_path = abspath("${path.module}/source/plugins")
    container_path = "/usr/local/searxng/searx/searx/plugins"
  }

  env = ["SEARXNG_BASE_URL=https://${var.host}"]

  capabilities {
    drop = ["ALL"]
    add = ["CHOWN", "SETGID", "SETUID", "DAC_OVERRIDE"]
  }

  log_driver = "json-file"
  log_opts = {
    "max-size" = "1m"
    "max-file" = "1"
  }

  depends_on = [
    docker_network.searx,
    docker_image.searx
  ]
}
