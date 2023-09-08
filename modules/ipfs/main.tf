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

  env = [ "IPFS_PROFILE=server" ]

  networks_advanced {
    name = var.network
  }

  ports {
    ip = "0.0.0.0"
    internal = 4001
    external = 4001
    protocol = "tcp"
  }
  ports {
    ip = "0.0.0.0"
    internal = 4001
    external = 4001
    protocol = "udp"
  }

  volumes {
    host_path = "/var/local/docker/ipfs/share"
    container_path = "/export"
  }
  volumes {
    host_path = "/var/local/docker/ipfs/data"
    container_path = "/data/ipfs"
  }

  depends_on = [
    docker_image.ipfs
  ]
}
