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
resource "docker_image" "postgres_latest" {
  name = "postgres:latest"
}
resource "docker_image" "redis" {
  name = "redis:alpine"
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

module "shareftp" {
  source = "./modules/shareftp"
  network = docker_network.internal_proxy.id

  host = var.shareftp_host
  username = var.shareftp_username
  password = var.shareftp_password
}

module "filestash" {
  source = "./modules/filestash"
  network = docker_network.internal_proxy.id

  config_secret = var.filestash_config_secret
}

module "rss-miniflux" {
  source = "./modules/rss-miniflux"
  network = docker_network.internal_proxy.id

  postgres_image = docker_image.postgres_latest.image_id
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
