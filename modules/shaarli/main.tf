terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "shaarli" {
  name = "ghcr.io/shaarli/shaarli:latest"
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
    host_path = abspath("./modules/shaarli/plugins/mastodon_validation")
    container_path = "/var/www/shaarli/plugins/mastodon_validation"
  }
  volumes {
    host_path = abspath("./modules/shaarli/plugins/webmention")
    container_path = "/var/www/shaarli/plugins/webmention"
  }

  depends_on = [
    docker_image.shaarli
  ]
}

