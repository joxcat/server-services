terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "filestash" {
  name = "filestash_internal"
}

resource "docker_image" "onlyoffice" {
  name = "onlyoffice/documentserver"
}
resource "docker_image" "filestash" {
  name = "machines/filestash"
}

resource "docker_volume" "filestash_config" {
  name = "caddy_data"
  driver = "rclone:latest"
  
  driver_opts = {
    path = "${var.sftp_path}/filestash/config"
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

resource "docker_container" "onlyoffice" {
  name = "onlyoffice"
  hostname = "onlyoffice"
  image = docker_image.onlyoffice.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.filestash.id
  }

  depends_on = [
    docker_network.filestash,
    docker_image.onlyoffice
  ]
}

resource "docker_container" "filestash" {
  name = "filestash"
  hostname = "filestash"
  image = docker_image.filestash.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.filestash.id
  }
  networks_advanced {
    name = var.network
  }

  env = [
    "APPLICATION_URL=",
    "ONLYOFFICE_URL=http://onlyoffice",
    "CONFIG_SECRET=${var.config_secret}"
  ]

  volumes {
    volume_name = docker_volume.filestash_config.name
    container_path = "/app/data/state"
  }
  volumes {
    host_path = abspath("${path.module}/local_data")
    container_path = "/data"
  }

  depends_on = [
    docker_network.filestash,
    docker_image.filestash
  ]
}
