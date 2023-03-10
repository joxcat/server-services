terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "pterodactyl" {
  name = "internal_pterodactyl"
}

resource "docker_network" "pterodactyl_wings" {
  name = "pterodactyl_nw"
  driver = "bridge"
  ipam_config {
    subnet = "172.21.0.0/16"
  }
  options = {
    "com.docker.network.bridge.name" = "pterodactyl_nw"
  }
}

resource "docker_image" "pterodactyl" {
  name = "ghcr.io/pterodactyl/panel:latest"
}

resource "docker_image" "pterodactyl_wings" {
  name = "ghcr.io/pterodactyl/wings:latest"
}

resource "docker_container" "pterodactyl_redis" {
  name = "pterodactyl_redis"
  hostname = "pterodactyl_redis"
  image = var.redis_image
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.pterodactyl.id
  }

  depends_on = [ docker_network.pterodactyl ]
}

resource "docker_container" "pterodactyl_database" {
  name = "pterodactyl_database"
  hostname = "pterodactyl_database"
  image = var.mariadb_image
  restart = "unless-stopped"

  command = ["--default-authentication-plugin=mysql_native_password"]

  networks_advanced {
    name = docker_network.pterodactyl.id
  }

  env = [
    "MYSQL_DATABASE=panel",
    "MYSQL_USER=pterodactyl",
    "MYSQL_PASSWORD=${var.mariadb_password}",
    "MARIADB_RANDOM_ROOT_PASSWORD=true"
  ]

  volumes {
    host_path = "/var/local/docker/pterodactyl/database"
    container_path = "/var/lib/mysql"
  }

  depends_on = [ docker_network.pterodactyl ]
}

resource "docker_container" "pterodactyl" {
  name = "pterodactyl"
  hostname = "pterodactyl"
  image = docker_image.pterodactyl.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.pterodactyl.id
  }

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/pterodactyl/var"
    container_path = "/app/var"
  }
  volumes {
    host_path = "/var/local/docker/pterodactyl/nginx"
    container_path = "/etc/nginx/http.d"
  }
  volumes {
    host_path = "/var/local/docker/pterodactyl/certs"
    container_path = "/etc/letsencrypt"
  }
  volumes {
    host_path = "/var/local/docker/pterodactyl/storage_logs"
    container_path = "/app/storage/logs"
  }
  volumes {
    host_path = "/var/local/docker/pterodactyl/logs"
    container_path = "/var/log"
  }

  env = [
    "APP_URL=${var.app_url}",
    "APP_TIMEZONE=Europe/Paris",
    "APP_SERVICE_AUTHOR=${var.mail}",
    "APP_DEBUG=true",
    "MAIL_FROM=${var.mail}",
    "MAIL_DRIVER=smtp",
    "MAIL_HOST=${var.smtp_host}",
    "MAIL_PORT=${var.smtp_port}",
    "MAIL_USERNAME=${var.smtp_username}",
    "MAIL_PASSWORD=${var.smtp_password}",
    "MAIL_ENCRYPTION=true",
    "DB_PASSWORD=${var.mariadb_password}",
    "APP_ENV=development",
    "APP_ENVIRONMENT_ONLY=false",
    "CACHE_DRIVER=redis",
    "SESSION_DRIVER=redis",
    "QUEUE_DRIVER=redis",
    "REDIS_HOST=pterodactyl_redis",
    "DB_HOST=pterodactyl_database",
    "DB_PORT=3306"
  ]

  depends_on = [
    docker_network.pterodactyl,
    var.network,
    docker_image.pterodactyl
  ]
}

resource "docker_container" "pterodactyl_wings1" {
  name = "pterodactyl_wings1"
  hostname = "pterodactyl_wings1"
  image = docker_image.pterodactyl_wings.image_id
  restart = "unless-stopped"

  env = [
    "TZ=UTC",
    "WINGS_UID=956",
    "WINGS_GID=956",
    "WINGS_USERNAME=pterodactyl"
  ]

  networks_advanced {
    name = var.network
  }

  networks_advanced {
    name = docker_network.pterodactyl_wings.id
  }

  ports {
    internal = 2022
    external = 2022
  }

  volumes {
    host_path = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  volumes {
    host_path = "/var/lib/docker/containers"
    container_path = "/var/lib/docker/containers"
  }
  volumes {
    host_path = "/tmp/pterodactyl"
    container_path = "/tmp/pterodactyl"
  }
  volumes {
    host_path = "/var/local/docker/pterodactyl/wings1/etc"
    container_path = "/etc/pterodactyl"
  }
  volumes {
    host_path = "/var/local/docker/pterodactyl/wings1/logs"
    container_path = "/var/local/docker/pterodactyl/wings1/logs"
  }
  volumes {
    host_path = "/var/local/docker/pterodactyl/wings1/lib"
    container_path = "/var/local/docker/pterodactyl/wings1/lib"
  }
  volumes {
    host_path = "/var/local/docker/pterodactyl/wings1/lib/volumes"
    container_path = "/var/local/docker/pterodactyl/wings1/lib/volumes"
  }
  volumes {
    host_path = "/var/local/docker/pterodactyl/wings1/lib/volumes"
    container_path = "/var/lib/pterodactyl/volumes"
  }

  depends_on = [
    var.network,
    docker_network.pterodactyl_wings,
    docker_image.pterodactyl_wings
  ]
}
