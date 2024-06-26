terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "ipfs" {
  name = "ipfs/kubo:v0.28.0"
}

resource "docker_container" "ipfs" {
  name = "ipfs"
  hostname = "ipfs"
  image = docker_image.ipfs.image_id
  restart = "unless-stopped"

  memory = 1024
  memory_swap = 1024

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
    source = "/var/lib/docker-data/ipfs/blocks"
    target = "/data/ipfs/blocks"
  }
  mounts {
    type = "bind"
    source = "/var/lib/docker-data/ipfs/data"
    target = "/data/ipfs"
  }

  depends_on = [
    docker_image.ipfs
  ]
}
