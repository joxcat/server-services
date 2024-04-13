terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "shaarli" {
  name = "ghcr.io/shaarli/shaarli:v0.13.0"
}

resource "docker_container" "shaarli" {
  name = "shaarli"
  hostname = "shaarli"
  image = docker_image.shaarli.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/shaarli/data"
    target = "/var/www/shaarli/data"
  }
  mounts {
    type = "bind"
    source = abspath("${path.module}/themes/stack/stack")
    target = "/var/www/shaarli/tpl/stack"
  }

  dynamic "mounts" {
    for_each = distinct(flatten([for _, v in flatten(fileset(path.module, "plugins/**")) : regex("plugins/([^/]*)", dirname(v))]))
    content {
      type = "bind"
      source = abspath("${path.module}/plugins/${mounts.value}")
      target = "/var/www/shaarli/plugins/${mounts.value}"
    }
  }

  depends_on = [
    docker_image.shaarli
  ]
}

