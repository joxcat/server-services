terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "archivebox" {
  name = "archivebox/archivebox:0.7.2"
}

resource "docker_container" "archivebox" {
  name = "archivebox"
  hostname = "archivebox"
  image = docker_image.archivebox.image_id
  restart = "unless-stopped"

  env = [
    # "ADMIN_USERNAME=",
    # "ADMIN_PASSWORD=",
    "ALLOWED_HOSTS=archive.fronce.fr",
    "PUBLIC_INDEX=True",
    "PUBLIC_SNAPSHOTS=True",
    "PUBLIC_ADD_VIEW=False",
    "CHECK_SSL_VALIDITY=False",
    "SAVE_ARCHIVE_DOT_ORG=True",
    "PUID=911",
    "PGID=911"
  ]

  networks_advanced {
    name = var.network
  }

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/archivebox/state"
    target = "/data"
  }
  mounts {
    type = "bind"
    source = "/var/lib/docker-data/archivebox/data"
    target = "/data/archive"
  }

  depends_on = [ docker_image.archivebox ]
}

