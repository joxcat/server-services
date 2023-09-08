terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource docker_image "jellyfin" {
  name = "lscr.io/linuxserver/jellyfin:latest"
}

resource docker_image "flood" {
  name = "jesec/flood:latest"
}

resource docker_image "rtorrent" {
  name = "jesec/rtorrent:latest"
}

resource docker_container "flood" {
  name = "seedbox_flood"
  hostname = "seedbox_flood"
  image = docker_image.flood.image_id
  restart = "unless-stopped"
  user = "1000:1001"

  env = [ "HOME=/config" ]
  command = [ "--port", "3001", "--allowedpath", "/data", "--baseuri", "/torrent" ]

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/seedbox/config"
    container_path = "/config"
  }
  volumes {
    host_path = "/var/local/docker/seedbox/data"
    container_path = "/data"
  }

  depends_on = [ docker_image.flood ]
}

resource docker_container "rtorrent" {
  name = "seedbox_rtorrent"
  hostname = "seedbox_rtorrent"
  image = docker_image.rtorrent.image_id
  restart = "unless-stopped"
  user = "1000:1001"

  env = [ "HOME=/config" ]
  command = [ "-o", "network.port_range.set=6881-6881,system.daemon.set=True" ]

  ports {
    external = "6881"
    internal = "6881"
  }

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/seedbox/config"
    container_path = "/config"
  }
  volumes {
    host_path = "/var/local/docker/seedbox/data"
    container_path = "/data"
  }

  depends_on = [ docker_image.rtorrent ]
}

resource docker_container "jellyfin" {
  name = "seedbox_jellyfin"
  hostname = "seedbox_jellyfin"
  image = docker_image.jellyfin.image_id
  restart = "unless-stopped"
  
  env = [
    "PUID=1000",
    "PGID=1001",
    "TZ=Europe/Paris",
  ]

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/seedbox/jellyfin_config"
    container_path = "/config"
  }
  volumes {
    host_path = "/var/local/docker/seedbox/data"
    container_path = "/home"
  }

  depends_on = [ docker_image.jellyfin ]
}
