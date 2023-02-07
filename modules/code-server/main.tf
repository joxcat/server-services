terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "code_server" {
  name = "code_server"
  build {
    context = "./modules/code-server"
    build_args = {
      UID = "${var.user_id}"
      GID = "${var.user_group}"
      GIT_NAME = var.git_name
      GIT_EMAIL = var.git_email
    }
  }
}

resource "docker_container" "code_server" {
  name = "code_server"
  hostname = "codeserver"
  image = docker_image.code_server.image_id
  restart = "unless-stopped"
  user = "${var.user_id}:${var.user_group}"

  memory = var.memory_limit

  devices {
    host_path = "/dev/fuse"
    container_path = "/dev/fuse"
  }

  networks_advanced {
    name = var.network
  }

  env = [
    "EXTENSIONS_GALLERY='{\"serviceUrl\": \"https://marketplace.visualstudio.com/_apis/public/gallery\",\"cacheUrl\":\"https://vscode.blob.core.windows.net/gallery/index\",\"itemUrl\":\"https://marketplace.visualstudio.com/items\"}'"
  ]

  // Needed for fuse
  capabilities {
    add = ["SYS_ADMIN"]
  }
  security_opts = ["apparmor:unconfined"]

  volumes {
    host_path = "/var/local/docker/code-server/app_data"
    container_path = "/user_home/.local"
  }
  volumes {
    host_path = "/var/local/docker/code-server/config"
    container_path = "/user_home/.config"
  }
  volumes {
    host_path = "/var/local/docker/code-server/data"
    container_path = "/user_home/data"
  }
  volumes {
    host_path = "/var/local/docker/code-server/ssh"
    container_path = "/user_home/.ssh"
  }
}
