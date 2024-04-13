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

resource "docker_container" "rss_forwarder" {
  name = "rss_forwarder"
  hostname = "rss_forwarder"
  image = docker_image.rss_forwarder.image_id
  restart = "unless-stopped"

  command = [ "rss-forwarder", "--debug", "/data/config.toml" ]

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/rss_forwarder/data"
    target = "/data"
  }

  depends_on = [
    docker_image.rss_forwarder
  ]
}

