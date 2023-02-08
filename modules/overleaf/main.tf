terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "overleaf" {
  name = "internal_overleaf"
}

resource "docker_image" "overleaf" {
  name = "overleaf"
  build {
    context = "./modules/overleaf"
  }
}

resource "docker_container" "redis" {
  name = "overleaf_redis"
  hostname = "redis"
  image = var.redis_image
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.overleaf.id
  }

  tmpfs = {
    "/var/lib/redis" = ""
  }

  depends_on = [
    docker_network.overleaf
  ]
}
resource "docker_container" "mongo" {
  name = "overleaf_mongo"
  hostname = "mongo"
  image = var.mongo_image
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.overleaf.id
  }

  volumes {
    host_path = "/var/local/docker/overleaf/mongo_data"
    container_path = "/data/db"
  }

  healthcheck {
    test = ["CMD", "echo", "db.stats().ok", "|", "mongo", "localhost:27017/test", "--quiet"]
    interval = "10s"
    timeout = "10s"
    retries = 5
  }

  depends_on = [
    docker_network.overleaf
  ]
}
resource "docker_container" "overleaf" {
  name = "overleaf"
  hostname = "overleaf"
  image = docker_image.overleaf.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.overleaf.id
  }
  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/overleaf/sharelatex_data"
    container_path = "/var/lib/sharelatex"
  }

  env = [
    "SHARELATEX_APP_NAME=Overleaf Community Edition",
    "SHARELATEX_MONGO_URL=mongodb://mongo/sharelatex",
    "SHARELATEX_REDIS_HOST=redis",
    "REDIS_HOST=redis",
    "ENABLED_LINKED_FILE_TYPES=project_file,project_output_file",
    "ENABLE_CONVERSIONS=true",
    "EMAIL_CONFIRMATION_DISABLED=true",
    "TEXMFVAR=/var/lib/sharelatex/tmp/texmf-var"
  ]

  depends_on = [
    docker_network.overleaf,
    docker_image.overleaf
  ]
}
