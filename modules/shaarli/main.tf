terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "shaarli" {
  name = "ghcr.io/shaarli/shaarli:v0.12.2"
}

resource "docker_container" "shaarli" {
  name = "shaarli"
  hostname = "shaarli"
  image = docker_image.shaarli.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/shaarli/data"
    container_path = "/var/www/shaarli/data"
  }
  volumes {
    host_path = "/var/local/docker/shaarli/cache"
    container_path = "/var/www/shaarli/cache"
  }
  volumes {
    host_path = abspath("${path.module}/plugins/mastodon_validation")
    container_path = "/var/www/shaarli/plugins/mastodon_validation"
  }
  volumes {
    host_path = abspath("${path.module}/plugins/webmention")
    container_path = "/var/www/shaarli/plugins/webmention"
  }
  volumes {
    host_path = abspath("${path.module}/plugins/webhook_on_create")
    container_path = "/var/www/shaarli/plugins/webhook_on_create"
  }
  volumes {
    host_path = abspath("${path.module}/themes/stack/stack")
    container_path = "/var/www/shaarli/tpl/stack"
  }

  depends_on = [
    docker_image.shaarli
  ]
}

