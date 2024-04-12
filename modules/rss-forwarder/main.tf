terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "rss_forwarder" {
  name = "rss-forwarder"
  build {
    context = path.module 
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "**") : filesha1(join("", [path.module, "/", f]))]))
  }
}

resource "docker_volume" "rss_forwarder_data" {
  name = "rss_forwarder_data"
  driver = "rclone:latest"
  
  driver_opts = {
    path = "${var.sftp_path}/rss_forwarder/data"
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

resource "docker_container" "rss_forwarder" {
  name = "rss_forwarder"
  hostname = "rss_forwarder"
  image = docker_image.rss_forwarder.image_id
  restart = "unless-stopped"

  command = [ "rss-forwarder", "--debug", "/data/config.toml" ]

  volumes {
    volume_name = docker_volume.rss_forwarder_data.name
    container_path = "/data"
  }

  depends_on = [
    docker_image.rss_forwarder
  ]
}

