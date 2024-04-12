terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "kellnr" {
  name = "ghcr.io/kellnr/kellnr:5.1.2"
}

resource "docker_volume" "kellnr_data" {
  name = "kellnr_data"
  driver = "rclone:latest"
  
  driver_opts = {
    path = "${var.sftp_path}/kellnr/data"
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

resource "docker_container" "kellnr" {
  name = "kellnr"
  hostname = "kellnr"
  image = docker_image.kellnr.image_id
  restart = "unless-stopped"

  env = [
    "KELLNR_ORIGIN__HOSTNAME=registry.tracto.pl",
    "KELLNR_ORIGIN__PORT=443",
    "KELLNR_ORIGIN__PROTOCOL=https",
    "KELLNR_DOCS__ENABLED=true"
  ]

  networks_advanced {
    name = var.network
  }

  volumes {
    volume_name = docker_volume.kellnr_data.name
    container_path = "/opt/kdata"
  }

  depends_on = [ docker_image.kellnr ]
}

