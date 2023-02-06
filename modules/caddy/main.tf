terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "caddy" {
  name = "caddy"
  build {
    context = "modules/caddy"
  }
}

resource "docker_container" "caddy" {
  name = "caddy"
  image = docker_image.caddy.image_id
  restart = "unless-stopped"
  entrypoint = ["caddy", "run", "--watch", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
  networks_advanced {
    name = var.network
  }

  volumes {
    host_path      = "/var/local/docker/caddy/data"
    container_path = "/data"
  }
  volumes {
    host_path      = "/var/local/docker/caddy/config"
    container_path = "/config"
  }
  volumes {
    host_path      = "/var/local/docker/caddy/Caddyfile"
    container_path = "/etc/caddy/Caddyfile"
  }
  volumes {
    host_path      = "/var/local/docker/caddy/caddyfiles"
    container_path = "/etc/caddy/caddyfiles"
  }

  ports {
    ip       = "65.21.230.238"
    external = 80
    internal = 80
  }
  ports {
    ip       = "2a01:4f9:6a:1d8f::2"
    external = 80
    internal = 80
  }
  ports {
    ip       = "65.21.230.238"
    external = 443
    internal = 443
  }
  ports {
    ip       = "2a01:4f9:6a:1d8f::2"
    external = 443
    internal = 443
  }

  depends_on = [
    docker_image.caddy
  ]
}
