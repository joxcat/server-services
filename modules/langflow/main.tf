terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "langflow" {
  name = "langflow"
  build {
    context = "./modules/langflow"
  }
}

resource "docker_container" "langflow" {
  name = "langflow"
  hostname = "langflow"
  image = docker_image.langflow.image_id
  restart = "unless-stopped"
  user = "1000:1000"

  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/langflow/data"
    container_path = "/home/user/app"
  }

  depends_on = [ docker_image.langflow ]
}
