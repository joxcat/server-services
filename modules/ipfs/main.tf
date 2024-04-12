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

resource "docker_volume" "ipfs_data" {
  name = "ipfs_data"
  driver = "rclone:latest"
  
  driver_opts = {
    path = "${var.sftp_path}/ipfs/data"
    type = "sftp"
    sftp-host = var.sftp_host
    sftp-port = var.sftp_port
    sftp-user = var.sftp_user
    sftp-pass = var.sftp_password
    allow-other = "true"
  }

  lifecycle {
    ignore_changes = all
  }
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
    internal = 4001
    external = 4001
    protocol = "tcp"
  }
  ports {
    internal = 4001
    external = 4001
    protocol = "udp"
  }

  volumes {
    volume_name = docker_volume.ipfs_data.name
    container_path = "/data/ipfs"
  }

  depends_on = [
    docker_image.ipfs
  ]
}
