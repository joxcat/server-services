terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "forgejo" {
  name = "codeberg.org/forgejo/forgejo:7.0.2"
}
/*resource "docker_image" "dind" {
  name = "docker:dind"
}
resource "docker_image" "forgejo_runner" {
  name = "code.forgejo.org/forgejo/runner:3.4.1"
}*/

/*resource "docker_network" "internal_forgejo" {
  name = "internal_forgejo"
}*/

resource "docker_container" "forgejo" {
  name = "forgejo"
  hostname = "forgejo"
  image = docker_image.forgejo.image_id
  restart = "unless-stopped"

  env = [ "USER_UID=1000", "USER_GID=1000" ]

  /*ports {
    internal = 22
    external = 22
  }*/

  networks_advanced {
    name = var.network
  }
  /*networks_advanced {
    name = docker_network.internal_forgejo.id
  }*/

  mounts {
    type = "bind"
    source = "/var/lib/docker-data/forgejo/data"
    target = "/data"
  }
  mounts {
    type = "bind"
    source = "/etc/timezone"
    target = "/etc/timezone"
    read_only = true
  }
  mounts {
    type = "bind"
    source = "/etc/localtime"
    target = "/etc/localtime"
    read_only = true
  }

  depends_on = [
    docker_image.forgejo,
    docker_network.internal_forgejo
  ]
}

/*resource "docker_container" "forgejo_dind" {
  name = "forgejo_dind"
  hostname = "forgejo_dind"
  image = docker_image.dind.image_id
  restart = "unless-stopped"
  privileged = true
  command = [ "dockerd", "-H", "tcp://0.0.0.0:2375", "--tls=false" ]

  networks_advanced {
    name = docker_network.internal_forgejo.id
  }

  depends_on = [
    docker_image.dind,
    docker_network.internal_forgejo
  ]
}*/

/* Disabled not used
resource "docker_container" "forgejo_runner" {
  name = "forgejo_runner"
  hostname = "forgejo_runner"
  image = docker_image.forgejo_runner.image_id
  restart = "unless-stopped"

  env = [ "DOCKER_HOST=tcp://forgejo_dind:2375" ]
  command = [ "forgejo-runner", "--config", "config.yml", "daemon" ]
  # forgejo-runner register --no-interactive --token {TOKEN} --name runner --instance http://forgejo:3000
  #command = [ "tail", "-f", "/dev/null" ]

  networks_advanced {
    name = docker_network.internal_forgejo.id
  }
  
  mounts {
    type = "bind"
    source = "/var/lib/docker-data/forgejo/runner"
    target = "/data"
  }

  depends_on = [
    docker_image.forgejo_runner,
    docker_container.forgejo_dind,
    docker_network.internal_forgejo
  ]
}*/
