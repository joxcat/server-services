terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "rclone" {
  name = "rclone/rclone:latest"
}

resource "docker_container" "rclone" {
  name = var.instance_name
  image = docker_image.rclone.image_id
  restart = "unless-stopped"

  devices {
    host_path = "/dev/fuse"
  }
  capabilities {
    add = ["SYS_ADMIN"]
  }

  command = [
    "mount",
    "--sftp-host", var.sftp_host,
    "--sftp-port", var.sftp_port,
    "--sftp-user", var.sftp_user,
    "--sftp-pass", var.sftp_password,
    "--allow-other",
    "--allow-non-empty",
    ":sftp:/home", "/data"
  ]
}

output "container_id" {
  value = docker_container.rclone.id
}
output "container_name" {
  value = docker_container.rclone.name
}