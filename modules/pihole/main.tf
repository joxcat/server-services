terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "pihole" {
  name = "pihole/pihole:2024.03.2"
}

resource "docker_container" "pihole" {
  name = "pihole"
  hostname = "pihole"
  image = docker_image.pihole.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  ports {
    internal = 53
    external = 53
    protocol = "tcp"
  }

  ports {
    internal = 53
    external = 53
    protocol = "udp"
  }

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/pihole/data"
    target = "/etc/pihole"
  }
  mounts {
    type = "bind"
    source = "/var/lib/docker-data/pihole/dnsmasq"
    target = "/etc/dnsmasq.d"
  }

  env = [
    "TZ=Europe/Paris",
    "DNSMASQ_LISTENING=all",
    "CORS_HOSTS=hole.planchon.dev",
    "PIHOLE_DNS_=",
    #"PIHOLE_DNS_=9.9.9.10;149.112.112.10;1.1.1.1;1.0.0.1;8.8.8.8;8.8.4.4",
  ]

  depends_on = [
    docker_image.pihole
  ]
}
