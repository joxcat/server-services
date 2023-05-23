terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "0.7.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "coder" {
  feature_use_managed_variables = "true"
}

data "coder_parameter" "install_script" {
  name        = "Install Script"
  type        = "string"
  description = "Command to run to install the application"
  mutable     = true
}
data "coder_parameter" "app_to_run" {
  name        = "Application to run"
  type        = "string"
  description = "Application that will be runned in KasmVNC"
  mutable     = true
}

locals {}

data "coder_provisioner" "me" {}

provider "docker" {}

data "coder_workspace" "me" {}

resource "coder_agent" "main" {
  arch           = data.coder_provisioner.me.arch
  os             = "linux"
  startup_script = <<EOF
    #!/bin/sh
    if [ -x "~/.autosetup" ]; then
      echo "running home .autosetup"
      ~/.autosetup
    fi
    EOF

  # These environment variables allow you to make Git commits right away after creating a
  # workspace. Note that they take precedence over configuration defined in ~/.gitconfig!
  # You can remove this block if you'd prefer to configure Git manually or using
  # dotfiles. (see docs/dotfiles.md)
  env = {
    GIT_AUTHOR_NAME     = "${data.coder_workspace.me.owner}"
    GIT_COMMITTER_NAME  = "${data.coder_workspace.me.owner}"
    GIT_AUTHOR_EMAIL    = "${data.coder_workspace.me.owner_email}"
    GIT_COMMITTER_EMAIL = "${data.coder_workspace.me.owner_email}"
  }
  metadata {
    display_name = "CPU Usage"
    key = "cpu"
    # calculates CPU usage by summing the "us", "sy" and "id" columns of
    # vmstat.
    script = <<EOT
    top -bn1 | awk 'FNR==3 {printf "%2.0f%%", $2+$3+$4}'
    EOT
    interval = 1
    timeout = 1
  }
  metadata {
    display_name = "Memory Usage"
    key = "mem"
    script = <<EOT
  cat /sys/fs/cgroup/memory.stat | awk '$1 ~ /^(active_anon|active_file|kernel)$/ { sum += $2 }; END { printf "%.2fMB", (sum / 1024 / 1024) }'
    EOT
    interval = 1
    timeout = 1
  }
  metadata {
    display_name = "Process Count"
    key = "proc"
    script = "ps aux | wc -l"
    interval = 1
    timeout = 3
  }
  metadata {
    display_name = "Permanent Data Size"
    key = "size"
    script = <<EOT
    du -h -d1 ~ | awk 'END { print $1 }'
    EOT
    interval = 60
    timeout = 10
  }
}

resource "coder_app" "kasm" {
  agent_id     = coder_agent.main.id
  slug         = "kasm"
  display_name = "KasmVNC"
  url          = "http://localhost:3000/"
  subdomain    = true
  share        = "owner"
}

resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace.me.id}-home"
  # Protect the volume from being deleted due to changes in attributes.
  lifecycle {
    ignore_changes = all
  }
  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "coder.owner"
    value = data.coder_workspace.me.owner
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace.me.owner_id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  # This field becomes outdated if the workspace is renamed but can
  # be useful for debugging or cleaning out dangling volumes.
  labels {
    label = "coder.workspace_name_at_creation"
    value = data.coder_workspace.me.name
  }
}
resource "coder_metadata" "home_volume" {
  count = data.coder_workspace.me.start_count
  resource_id = docker_volume.home_volume.id
  hide = true

  item {
    key = "id"
    value = docker_volume.home_volume.name
  }
}


resource "docker_image" "main" {
  name = "coder-${data.coder_workspace.me.id}-kasm"
  build {
    context = "./build"
    build_args = {
      INSTALL_SCRIPT = "${data.coder_parameter.install_script.value}"
      APP_TO_RUN = "${data.coder_parameter.app_to_run.value}"
      CODER_INIT_SCRIPT = replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")
    }
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "build/*") : filesha1(f)]))
  }
}
resource "coder_metadata" "hide_docker_image" {
  count = data.coder_workspace.me.start_count
  resource_id = docker_image.main.image_id
  hide = true
}

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = docker_image.main.name
  # Uses lower() to avoid Docker restriction on container names.
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}"
  # Hostname makes the shell more user friendly: coder@my-workspace:~$
  hostname = data.coder_workspace.me.name
  # Use the docker gateway if the access URL is 127.0.0.1
  entrypoint = ["/init"]
  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
    "CUSTOM_USER=",
    "PASSWORD=",
    "TITLE=${data.coder_workspace.me.name}",
    "PUID=0",
    "PGID=0"
  ]
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  volumes {
    container_path = "/config"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }
  security_opts = ["seccomp=unconfined"]

  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "coder.owner"
    value = data.coder_workspace.me.owner
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace.me.owner_id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
}

