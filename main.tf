terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}
provider "docker" {}

# Networks
resource "docker_network" "internal_proxy" {
  name = "internal_proxy"
}

/*module "tailscale" {
  source = "./modules/tailscale"
  network = docker_network.internal_proxy.id
  auth_key = var.tailscale_auth_key
}*/

# Modules
module "caddy" {
  source = "./modules/caddy"
  network = docker_network.internal_proxy.id
}

module "polr" {
  source = "./modules/polr"
  network = docker_network.internal_proxy.id

  mysql_password = var.polr_mysql_password
  app_name = var.polr_app_name
  app_address = var.polr_app_address
  default_admin_username = var.polr_default_admin_username
  default_admin_password = var.polr_default_admin_password
}

module "rss-bridge" {
  source = "./modules/rss-bridge"
  network = docker_network.internal_proxy.id
}

module "filestash" {
  source = "./modules/filestash"
  network = docker_network.internal_proxy.id

  config_secret = var.filestash_config_secret
}

module "rss-miniflux" {
  source = "./modules/rss-miniflux"
  network = docker_network.internal_proxy.id

  database_password = var.rss_miniflux_database_password
}

/* // Unused 
module "wordpress-vic" {
  source = "./modules/wordpress"
  network = docker_network.internal_proxy.id

  resource_prefix = "vic"
  database_password = var.wordpress_vic_database_password
}
*/

/* // Disabling, moved to Kagi
module "searx" {
  source = "./modules/searx"
  network = docker_network.internal_proxy.id

  host = var.searx_host
}*/

module "coder" {
  source = "./modules/coder"
  network = docker_network.internal_proxy.id

  postgres_password = var.coder_postgres_password 
  access_url = var.coder_access_url
  wildcard_url = var.coder_wildcard_url
  docker_group_id = "978"
}

/* // Not used, too much support needed
module "pterodactyl" {
  source = "./modules/pterodactyl"
  network = docker_network.internal_proxy.id

  mariadb_password = var.pterodactyl_mariadb_password
  app_url = var.pterodactyl_app_url
  mail = var.pterodactyl_mail
  smtp_host = var.pterodactyl_smtp_host
  smtp_port = var.pterodactyl_smtp_port
  smtp_username = var.pterodactyl_smtp_username
  smtp_password = var.pterodactyl_smtp_password
} */

module "ipfs" {
  source = "./modules/ipfs"
  network = docker_network.internal_proxy.id
}

/* // Near 1G of RAM usage wtf
module "kroki" {
  source = "./modules/kroki"
  network = docker_network.internal_proxy.id
}
*/

module "umami" {
  source = "./modules/umami"
  network = docker_network.internal_proxy.id

  postgres_password = var.umami_postgres_password
  app_secret = var.umami_app_secret
}

/* // Not used
module "komga" {
  source = "./modules/komga"
  network = docker_network.internal_proxy.id
}
*/

/* // Not used
module "grocy" {
  source = "./modules/grocy"
  network = docker_network.internal_proxy.id
}
*/

/* // Useless as it is
module "supabase" {
  source = "./modules/supabase"
  network = docker_network.internal_proxy.id

  disable_signup = "false"
  site_url = var.supabase_site_url
  api_external_url = "${var.supabase_site_url}/proxy"

  postgres_password = var.supabase_postgres_password
  smtp_host = var.supabase_smtp_host
  smtp_port = var.supabase_smtp_port
  smtp_user = var.supabase_smtp_user
  smtp_password = var.supabase_smtp_password
  smtp_sender = var.supabase_smtp_sender
  smtp_admin_email = var.supabase_smtp_admin_email
  studio_public_url = "${var.supabase_site_url}/proxy"
  jwt_secret = var.supabase_jwt_secret
}
*/

module "seedbox" {
  source = "./modules/seedbox"
  network = docker_network.internal_proxy.id
}

module "shaarli" {
  source = "./modules/shaarli"
  network = docker_network.internal_proxy.id
}

/* // Moved to lobe-chat
module "chat_with_gpt" {
  source = "./modules/chat-with-gpt"
  network = docker_network.internal_proxy.id
}
*/
/* // Really good but not ready yet
module "lobe_chat" {
  source = "./modules/lobe-chat"
  network = docker_network.internal_proxy.id
}
*/
module "ollama" {
  source = "./modules/ollama"
  network = docker_network.internal_proxy.id
}

module "concourse" {
  source = "./modules/concourse"
  network = docker_network.internal_proxy.id
  postgres_password = var.concourse_postgres_password
  concourse_add_local_user = var.concourse_add_local_user
  concourse_main_team_local_user = var.concourse_main_team_local_user
}

/* // NOT Ready yet
module "grist" {
  source = "./modules/grist"
  network = docker_network.internal_proxy.id
}
*/

/* // Not using them for the moment
module "langflow" {
  source = "./modules/langflow"
  network = docker_network.internal_proxy.id
}*/

/* // Not using them for the moment
module "flowise" {
  source = "./modules/flowise"
  network = docker_network.internal_proxy.id

  flowise_username = var.flowise_username
  flowise_password = var.flowise_password
}*/

module "kellnr" {
  source = "./modules/kellnr"
  network = docker_network.internal_proxy.id
}

/* // Not used
module "paperless" {
  source = "./modules/paperless"
  network = docker_network.internal_proxy.id
}*/

module "rss_forwarder" {
  source = "./modules/rss-forwarder"
}

module "forgejo" {
  source = "./modules/forgejo"
  network = docker_network.internal_proxy.id
}

module "homepage" {
  source = "./modules/homepage"
  network = docker_network.internal_proxy.id
  docker_group_id = "978"
}

module "n8n" {
  source = "./modules/n8n"
  network = docker_network.internal_proxy.id

  base_url = var.n8n_base_url
}

module "nocodb" {
  source = "./modules/nocodb"
  network = docker_network.internal_proxy.id
}

module "archivebox" {
  source = "./modules/archivebox"
  network = docker_network.internal_proxy.id
}
