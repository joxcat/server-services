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

# Common images
resource "docker_image" "mysql_8" {
  name = "mysql:8"
}
resource "docker_image" "postgres_14" {
  name = "postgres:14"
}
resource "docker_image" "postgres_15" {
  name = "postgres:15-alpine"
}
resource "docker_image" "redis" {
  name = "redis:alpine"
}
resource "docker_image" "redis_5" {
  name = "redis:5"
}
resource "docker_image" "redis_7" {
  name = "redis:7"
}
resource "docker_image" "mongo_4" {
  name = "mongo:4.0"
}
resource "docker_image" "mariadb" {
  name = "mariadb:latest"
}
resource "docker_image" "mariadb_10" {
  name = "mariadb:10.5"
}

# Modules
module "caddy" {
  source = "./modules/caddy"
  network = docker_network.internal_proxy.id
}

module "polr" {
  source = "./modules/polr"
  mysql_image = docker_image.mysql_8.image_id
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

  postgres_image = docker_image.postgres_14.image_id
  database_password = var.rss_miniflux_database_password
}

/* // Unused 
module "wordpress-vic" {
  source = "./modules/wordpress"
  network = docker_network.internal_proxy.id

  mysql_image = docker_image.mysql_8.image_id
  resource_prefix = "vic"
  database_password = var.wordpress_vic_database_password
}
*/

/* // Disabling, moved to Kagi
module "searx" {
  source = "./modules/searx"
  network = docker_network.internal_proxy.id

  redis_image = docker_image.redis.image_id
  host = var.searx_host
}*/

module "coder" {
  source = "./modules/coder"
  network = docker_network.internal_proxy.id

  postgres_image = docker_image.postgres_14.image_id
  postgres_password = var.coder_postgres_password 
  access_url = var.coder_access_url
  wildcard_url = var.coder_wildcard_url
  docker_group_id = "974"
}

module "pterodactyl" {
  source = "./modules/pterodactyl"
  network = docker_network.internal_proxy.id

  mariadb_image = docker_image.mariadb_10.image_id
  redis_image = docker_image.redis.image_id
  mariadb_password = var.pterodactyl_mariadb_password
  app_url = var.pterodactyl_app_url
  mail = var.pterodactyl_mail
  smtp_host = var.pterodactyl_smtp_host
  smtp_port = var.pterodactyl_smtp_port
  smtp_username = var.pterodactyl_smtp_username
  smtp_password = var.pterodactyl_smtp_password
}

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

  postgres_image = docker_image.postgres_15.image_id
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
  postgres_image = docker_image.postgres_15.image_id
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

module "flowise" {
  source = "./modules/flowise"
  network = docker_network.internal_proxy.id

  flowise_username = var.flowise_username
  flowise_password = var.flowise_password
}

module "kellnr" {
  source = "./modules/kellnr"
  network = docker_network.internal_proxy.id
}

/* // Not used
module "paperless" {
  source = "./modules/paperless"
  network = docker_network.internal_proxy.id

  redis_image = docker_image.redis_7.image_id
}*/

module "rss_forwarder" {
  source = "./modules/rss-forwarder"
}

module "forgejo" {
  source = "./modules/forgejo"
  network = docker_network.internal_proxy.id
}
