terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "grist" {
  name = "gristlabs/grist:1.1.6"
}

resource "docker_container" "grist" {
  name = "grist"
  hostname = "grist"
  image = docker_image.grist.image_id
  restart = "unless-stopped"

  env = [
    "GRIST_SESSION_SECRET=wow-that-is-a-s3cr3t",
    "GRIST_SANDBOX_FLAVOR=",
    "APP_HOME_URL=https://sheet.reta.re",
    "GRIST_DOMAIN=sheet.reta.re",
    "GRIST_SINGLE_ORG=uwu",
    "GRIST_HIDE_UI_ELEMENTS=billing",
    "GRIST_PAGE_TITLE_SUFFIX= - luv <3",
    "GRIST_WIDGET_LIST_URL=https://github.com/gristlabs/grist-widget/releases/download/latest/manifest.json",
    "GRIST_FORCE_LOGIN=false",
    "GRIST_ANON_PLAYGROUND=true",
    "GRIST_TELEMETRY_LEVEL=off"
  ]


  networks_advanced {
    name = var.network
  }

  volumes {
    host_path = "/var/local/docker/grist/data"
    container_path = "/persist"
  }

  depends_on = [ docker_image.grist ]
}
