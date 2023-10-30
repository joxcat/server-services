terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "concourse" {
  name = "concourse/concourse:7.10.0"
}

resource "docker_network" "internal_concourse" {
  name = "internal_concourse"
}

resource "docker_container" "concourse_db" {
  name = "concourse_db"
  hostname = "concourse_db"
  image = var.postgres_image
  restart = "unless-stopped"

  env = [
    "POSTGRES_DB=concourse",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_USER=concourse_user",
    "PGDATA=/database"
  ]

  networks_advanced {
    name = docker_network.internal_concourse.id
  }

  volumes {
    host_path = "/var/local/docker/concourse/data"
    container_path = "/database"
  }
}

resource "docker_container" "concourse_worker" {
  name = "concourse_worker"
  hostname = "concourse_worker"
  image = docker_image.concourse.image_id
  restart = "unless-stopped"

  command = [ "worker" ]
  privileged = true

  env = [
    "CONCOURSE_RUNTIME=containerd",
    "CONCOURSE_TSA_PUBLIC_KEY=/concourse-keys/tsa_host_key.pub",
    "CONCOURSE_TSA_WORKER_PRIVATE_KEY=/concourse-keys/worker_key",
    "CONCOURSE_TSA_HOST=concourse:2222",
    "CONCOURSE_BIND_IP=0.0.0.0",
    "CONCOURSE_BAGGAGECLAIM_BIND_IP=0.0.0.0",
    "CONCOURSE_BAGGAGECLAIM_DRIVER=overlay",
    "CONCOURSE_CONTAINERD_DNS_PROXY_ENABLE=true"
  ]

  volumes {
    host_path = "/var/local/docker/concourse/keys"
    container_path = "/concourse-keys"
  }

  networks_advanced {
    name = docker_network.internal_concourse.id
  }

  depends_on = [
    docker_network.internal_concourse,
    docker_container.concourse
  ]
}

resource "docker_container" "concourse" {
  name = "concourse"
  hostname = "concourse"
  image = docker_image.concourse.image_id
  restart = "unless-stopped"

  command = [ "web" ]

  env = [
    "CONCOURSE_SESSION_SIGNING_KEY=/concourse-keys/session_signing_key",
    "CONCOURSE_TSA_AUTHORIZED_KEYS=/concourse-keys/authorized_worker_keys",
    "CONCOURSE_TSA_HOST_KEY=/concourse-keys/tsa_host_key",
    "CONCOURSE_POSTGRES_HOST=concourse_db",
    "CONCOURSE_POSTGRES_USER=concourse_user",
    "CONCOURSE_POSTGRES_PASSWORD=${var.postgres_password}",
    "CONCOURSE_POSTGRES_DATABASE=concourse",
    "CONCOURSE_EXTERNAL_URL=https://cicd.planchon.dev",
    "CONCOURSE_ADD_LOCAL_USER=${var.concourse_add_local_user}",
    "CONCOURSE_MAIN_TEAM_LOCAL_USER=${var.concourse_main_team_local_user}",
    "CONCOURSE_CLUSTER_NAME=dev"
  ]

  volumes {
    host_path = "/var/local/docker/concourse/keys"
    container_path = "/concourse-keys"
  }

  networks_advanced {
    name = var.network
  }
  networks_advanced {
    name = docker_network.internal_concourse.id
  }

  depends_on = [
    docker_network.internal_concourse,
    docker_container.concourse_db
  ]
}