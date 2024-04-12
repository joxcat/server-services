terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "caddy" {
  name = "caddy"
  build {
    context = path.module
  }
}

resource "docker_volume" "caddy_data" {
  name = "caddy_data"
  driver = "rclone:latest"
  
  driver_opts = {
    path = "${var.sftp_path}/caddy/data"
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
resource "docker_volume" "caddy_state" {
  name = "caddy_state"
  driver = "rclone:latest"
  
  driver_opts = {
    path = "${var.sftp_path}/caddy/state"
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
resource "docker_volume" "caddy_config" {
  name = "caddy_config"
  driver = "rclone:latest"
  
  driver_opts = {
    path = "${var.sftp_path}/caddy/config"
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

resource "docker_container" "caddy" {
  name = "caddy"
  image = docker_image.caddy.image_id
  restart = "unless-stopped"
  entrypoint = ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
  
  networks_advanced {
    name = var.network
  }
  networks_advanced {
    name = "bridge"
  }

  host {
    host  = "host.docker.internal"
    ip    = "host-gateway"
  }

  volumes {
    volume_name = docker_volume.caddy_data.name
    container_path = "/data"
  }
  volumes {
    volume_name = docker_volume.caddy_state.name
    container_path = "/config"
  }
  volumes {
    volume_name = docker_volume.caddy_config.name
    container_path = "/etc/caddy"
  }
  ports {
    external = 80
    internal = 80
    protocol = "tcp"
  }
  ports {
    external = 80
    internal = 80
    protocol = "udp"
  }
  ports {
    external = 443
    internal = 443
    protocol = "tcp"
  }
  ports {
    external = 443
    internal = 443
    protocol = "udp"
  }

  depends_on = [
    docker_image.caddy
  ]
}
