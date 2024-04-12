terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "shaarli" {
  name = "ghcr.io/shaarli/shaarli:v0.13.0"
}

resource "docker_volume" "shaarli_data" {
  name = "shaarli_data"
  driver = "rclone:latest"
  
  driver_opts = {
    path = "${var.sftp_path}/shaarli/data"
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

resource "docker_container" "shaarli" {
  name = "shaarli"
  hostname = "shaarli"
  image = docker_image.shaarli.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  volumes {
    volume_name = docker_volume.shaarli_data.name
    container_path = "/var/www/shaarli/data"
  }
  volumes {
    host_path = abspath("${path.module}/themes/stack/stack")
    container_path = "/var/www/shaarli/tpl/stack"
  }

  dynamic "volumes" {
    for_each = distinct(flatten([for _, v in flatten(fileset(path.module, "plugins/**")) : regex("plugins/([^/]*)", dirname(v))]))
    content {
      host_path = abspath("${path.module}/plugins/${volumes.value}")
      container_path = "/var/www/shaarli/plugins/${volumes.value}"
    }
  }

  depends_on = [
    docker_image.shaarli
  ]
}

