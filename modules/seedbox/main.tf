terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource docker_network "internal_seedbox" {
  name = "internal_seedbox"
}

resource docker_image "jellyfin" {
  name = "lscr.io/linuxserver/jellyfin:latest"
}

resource docker_image "flood" {
  name = "jesec/flood:master"
}

// Because of https://github.com/jesec/rtorrent/issues/53
resource docker_image "rtorrent" {
  name = "rtorrent:alpine"
  // name = "jesec/rtorrent:master-amd64"
  build {
    context = "${path.module}/rtorrent"
  }
}

resource docker_image "jfa_go" {
  name = "hrfee/jfa-go"
}

resource docker_image "radarr" {
  name = "lscr.io/linuxserver/radarr:latest"
}

resource docker_image "sonarr" {
  name = "lscr.io/linuxserver/sonarr:latest"
}

/*resource docker_image "nzbget" {
  name = "lscr.io/linuxserver/nzbget:latest"
}*/

/*resource docker_image "reiverr" {
  name = "ghcr.io/aleksilassila/reiverr:latest"
}*/

resource docker_image "prowlarr" {
  name = "lscr.io/linuxserver/prowlarr:latest"
}

resource docker_image "flaresolverr" {
  name = "ghcr.io/flaresolverr/flaresolverr:latest"
}

resource docker_container "flood" {
  name = "seedbox_flood"
  hostname = "seedbox_flood"
  image = docker_image.flood.image_id
  restart = "unless-stopped"
  user = "1000:1001"

  env = [ "HOME=/config" ]
  command = [
    "--port", "3001",
    "--allowedpath", "/data",
    "--allowedpath", "/config",
    "--baseuri", "/torrent"
  ]

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

  depends_on = [
    docker_image.flood,
    docker_container.rtorrent
  ]
}

resource docker_container "radarr" {
  name = "seedbox_radarr"
  hostname = "seedbox_radarr"
  image = docker_image.radarr.image_id
  restart = "unless-stopped"

  env = [ "PUID=1000", "PGID=1001", "TZ=Europe/Paris" ]

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/seedbox/radarr_config"
    container_path = "/config"
  }
  volumes {
    host_path = "/var/local/docker/seedbox/config/.local/share/rtorrent"
    container_path = "/config/.local/share/rtorrent"
  }
  volumes {
    host_path = "/var/local/docker/seedbox/data"
    container_path = "/data"
  }

  depends_on = [
    docker_image.radarr,
    docker_container.flood
  ]
}

resource docker_container "sonarr" {
  name = "seedbox_sonarr"
  hostname = "seedbox_sonarr"
  image = docker_image.sonarr.image_id
  restart = "unless-stopped"

  env = [ "PUID=1000", "PGID=1001", "TZ=Europe/Paris" ]

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/seedbox/sonarr_config"
    container_path = "/config"
  }
  volumes {
    host_path = "/var/local/docker/seedbox/config/.local/share/rtorrent"
    container_path = "/config/.local/share/rtorrent"
  }
  volumes {
    host_path = "/var/local/docker/seedbox/data"
    container_path = "/data"
  }

  depends_on = [
    docker_image.sonarr,
    docker_container.flood
  ]
}

resource docker_container "prowlarr" {
  name = "seedbox_prowlarr"
  hostname = "seedbox_prowlarr"
  image = docker_image.prowlarr.image_id
  restart = "unless-stopped"

  env = [ "PUID=1000", "PGID=1001", "TZ=Europe/Paris" ]

  networks_advanced {
    name = var.network
  }
  networks_advanced {
    name = docker_network.internal_seedbox.id
  }

  volumes {
    host_path = "/var/local/docker/seedbox/prowlarr_config"
    container_path = "/config"
  }

  depends_on = [ docker_image.prowlarr ]
}

/*resource docker_container "nzbget" {
  name = "seedbox_nzbget"
  hostname = "seedbox_nzbget"
  image = docker_image.nzbget.image_id
  restart = "unless-stopped"

  env = [ "PUID=1000", "PGID=1001", "TZ=Europe/Paris" ]

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/seedbox/nzbget_config"
    container_path = "/config"
  }
  volumes {
    host_path = "/var/local/docker/seedbox/data"
    container_path = "/data"
  }

  depends_on = [ docker_image.nzbget ]
}*/

resource docker_container "flaresolverr" {
  name = "seedbox_flaresolverr"
  hostname = "seedbox_flaresolverr"
  image = docker_image.flaresolverr.image_id
  restart = "unless-stopped"

  env = [
    "LOG_LEVEL=info",
    "LOG_HTML=false",
    "CAPTCHA_SOLVER=none",
    "TZ=Europe/Paris"
  ]

  networks_advanced {
    name = docker_network.internal_seedbox.id
  }

  depends_on = [
    docker_image.flaresolverr,
    docker_network.internal_seedbox
  ]
}

resource docker_container "rtorrent" {
  name = "seedbox_rtorrent"
  hostname = "seedbox_rtorrent"
  image = docker_image.rtorrent.image_id
  restart = "unless-stopped"
  user = "1000:1001"

  env = [ "HOME=/config" ]
  command = [ "-o", "system.daemon.set=true" ]

  memory = 5120
  memory_swap = 8192

  ports {
    external = "6881"
    internal = "6881"
    protocol = "tcp"
  }
  ports {
    external = "6881"
    internal = "6881"
    protocol = "udp"
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

resource docker_container "jfa-go" {
  name = "seedbox_jfago"
  hostname = "seedbox_jfago"
  image = docker_image.jfa_go.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/seedbox/jfago"
    container_path = "/data"
  }
  volumes {
    host_path = "/var/local/docker/seedbox/jellyfin_config"
    container_path =  "/jf"
  }
  volumes {
    host_path = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only = true
  }

  depends_on = [ docker_image.jfa_go ]
}

/*resource docker_container "reiverr" {
  name = "seedbox_reiverr"
  hostname = "seedbox_reiverr"
  image = docker_image.reiverr.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/seedbox/reiverr_config"
    container_path = "/config"
  }

  depends_on = [ docker_image.reiverr ]
}*/

