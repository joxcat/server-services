terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "ipfs" {
  name = "ipfs/kubo:latest"
}

resource "docker_container" "ipfs" {
  name = "ipfs"
  hostname = "ipfs"
  image = docker_image.ipfs.image_id
  restart = "unless-stopped"

  memory = 1024

  env = [ "IPFS_PROFILE=server" ]

  networks_advanced {
    name = var.network
  }

  ports {
    internal = 4001
    external = 4001
    protocol = "tcp"
  }
  ports {
    internal = 4001
    external = 4001
    protocol = "udp"
  }

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/ipfs/config"
    target = "/data/ipfs/config"
  }
  mounts {
    type = "bind"
    source = "/var/lib/docker-data/ipfs/blocks"
    target = "/data/ipfs/blocks"
  }

  depends_on = [
    docker_image.ipfs
  ]
}
