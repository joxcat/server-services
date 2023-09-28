terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "coder" {}

data "coder_parameter" "git_repo" {
  name        = "Git Repository"
  type        = "string"
  description = "Default git repository"
  mutable     = true
  default     = ""

  validation {
    regex = "^(git@([a-zA-Z0-9-_.]+):(([a-zA-Z0-9-_.~]+)\\/)+[a-zA-Z0-9-_.]+|(https:\\/\\/[a-zA-Z0-9-_.]+\\/([a-zA-Z0-9-_.]+\\/)+)[a-zA-Z0-9-_.]+|)$"
    error = "Unfortunately, it isn't a supported git url"
  }
}

locals {
  username = data.coder_workspace.me.owner
  git_folder = data.coder_parameter.git_repo.value != "" ? regex("[a-zA-Z0-9-_]+/(?P<folder>[a-zA-Z0-9-_]+)(?P<git>.git)?$", data.coder_parameter.git_repo.value).folder : ""
}

data "coder_provisioner" "me" {}

provider "docker" {}

data "coder_workspace" "me" {}

resource "coder_agent" "main" {
  arch           = data.coder_provisioner.me.arch
  os             = "linux"
  startup_script = <<EOF
    set -e

    mkdir -p ~/.local/share
    sudo chown coder:coder ~/.local
    sudo chown coder:coder ~/.local/share

    # clone git if provided 
    if [ ! -z "${data.coder_parameter.git_repo.value}" ] && [ ! -d "${local.git_folder}" ]; then
      mkdir -p ~/.ssh
      ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
      git clone ${data.coder_parameter.git_repo.value} ${local.git_folder}
    fi

    # install and start code-server
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server
    rm -f /tmp/code-server.log
    /tmp/code-server/bin/code-server --install-extension rust-lang.rust-analyzer >>/tmp/code-server.log 2>&1 &
    /tmp/code-server/bin/code-server --install-extension tamasfe.even-better-toml >>/tmp/code-server.log 2>&1 &
    /tmp/code-server/bin/code-server --install-extension usernamehw.errorlens >>/tmp/code-server.log 2>&1 &
    /tmp/code-server/bin/code-server --auth none --port 13337 >>/tmp/code-server.log 2>&1 &

    # if found run .autosetup
    if [ ! -z "${local.git_folder}" ] && [ -x "${local.git_folder}/.autosetup" ]; then
      echo "running ${local.git_folder} .autosetup"
      "./${local.git_folder}/.autosetup"
    elif [ -x "~/.autosetup" ]; then
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
    key = "0_cpu_usage"
    script = "top -bn1 | awk 'FNR==3 {printf \"%2.0f%%\", $2+$3+$4}'"
    interval = 10
    timeout = 1
  }
  metadata {
    display_name = "RAM Usage"
    key = "1_ram_usage"
    script = "cat /sys/fs/cgroup/memory.stat | awk '$1 ~ /^(active_anon|active_file|kernel)$/ { sum += $2 }; END { printf \"%.2fMB\", sum/1024/1024 }'"
    interval = 10
    timeout = 1
  }
  metadata {
    display_name = "Process Count"
    key = "2_proc_count"
    script = "ps aux | wc -l"
    interval = 10
    timeout = 3
  }
  metadata {
    display_name = "Home Disk"
    key = "3_home_disk"
    script = "du -h -d1 ~ | awk 'END { print $1 }'"
    interval = 60
    timeout = 1
  }
  metadata {
    display_name = "Load Average (Host)"
    key = "6_load_host"
    # get load avg scaled by number of cores
    script = <<EOT
      echo "`cat /proc/loadavg | awk '{ print $1 }'` `nproc`" | awk '{ printf "%0.2f", $1/$2 }'
    EOT
    interval = 60
    timeout  = 1
  }
}

resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "code-server"
  url          = "http://localhost:13337/?folder=/home/coder/${local.git_folder}"
  icon         = "/icon/code.svg"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 5
    threshold = 6
  }
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

resource "docker_image" "main" {
  name = "coder-${data.coder_workspace.me.id}-rust"
  build {
    context = "./build"
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "build/*") : filesha1(f)]))
  }
}

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = docker_image.main.name
  # Uses lower() to avoid Docker restriction on container names.
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}"
  # Hostname makes the shell more user friendly: coder@my-workspace:~$
  hostname = data.coder_workspace.me.name
  # Use the docker gateway if the access URL is 127.0.0.1
  entrypoint = ["sh", "-c", replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")]
  env        = ["CODER_AGENT_TOKEN=${coder_agent.main.token}"]
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  volumes {
    container_path = "/home/coder/"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }
  volumes {
    container_path = "/nix"
    volume_name    = "coder-nix" 
    read_only      = false
  }

  // So we can GDB in Docker
  capabilities {
    add = ["SYS_PTRACE"]
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

