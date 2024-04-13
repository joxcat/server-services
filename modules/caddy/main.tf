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
    context = path.module
  }
}

resource "docker_container" "caddy" {
  name = "caddy"
  image = docker_image.caddy.image_id
  restart = "unless-stopped"
  entrypoint = ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
  
  networks_advanced {
    name = var.network
  }
  networks_advanced {
    name = "bridge"
  }

  host {
    host  = "host.docker.internal"
    ip    = "host-gateway"
  }

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/caddy/data"
    target = "/data"
  }
  mounts {
    type = "bind"
    source = "/var/lib/docker-data/caddy/state"
    target = "/config"
  }
  mounts {
    type = "bind"
    source = "/var/lib/docker-data/caddy/config"
    target = "/etc/caddy"
  }
  ports {
    external = 80
    internal = 80
    protocol = "tcp"
  }
  ports {
    external = 80
    internal = 80
    protocol = "udp"
  }
  ports {
    external = 443
    internal = 443
    protocol = "tcp"
  }
  ports {
    external = 443
    internal = 443
    protocol = "udp"
  }

  depends_on = [
    docker_image.caddy
  ]
}
