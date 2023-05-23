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
resource "docker_image" "redis" {
  name = "redis:alpine"
}
resource "docker_image" "redis_5" {
  name = "redis:5"
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

/* module "shareftp" {
  source = "./modules/shareftp"
  network = docker_network.internal_proxy.id

  host = var.shareftp_host
  username = var.shareftp_username
  password = var.shareftp_password
} */

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

module "wordpress-vic" {
  source = "./modules/wordpress"
  network = docker_network.internal_proxy.id

  mysql_image = docker_image.mysql_8.image_id
  resource_prefix = "vic"
  database_password = var.wordpress_vic_database_password
}

module "searx" {
  source = "./modules/searx"
  network = docker_network.internal_proxy.id

  redis_image = docker_image.redis.image_id
  host = var.searx_host
}

module "overleaf" {
  source = "./modules/overleaf"
  network = docker_network.internal_proxy.id

  redis_image = docker_image.redis_5.image_id
  mongo_image = docker_image.mongo_4.image_id
}

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

module "kroki" {
  source = "./modules/kroki"
  network = docker_network.internal_proxy.id
}
