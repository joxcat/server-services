# Polr
variable "polr_mysql_password" {
  description = "Polr's MySQL password"
  type = string
  default = "polr"
}
variable "polr_app_name" {
  description = "Polr's displayed name"
  type = string
  default = "Polr"
}
variable "polr_app_address" {
  description = "Polr's exposed host"
  type = string
}
variable "polr_default_admin_username" {
  description = "Polr's default admin username"
  type = string
}
variable "polr_default_admin_password" {
  description = "Polr's default admin password"
  type = string
}

# ShareFTP
variable "shareftp_host" {
  description = "ShareFTP host"
  type = string
}
variable "shareftp_username" {
  description = "ShareFTP Basic Auth username"
  type = string
}
variable "shareftp_password" {
  description = "ShareFTP Basic Auth password"
  type = string
}

# Filestash
variable "filestash_config_secret" {
  description = "Filestash's config encryption secret"
  type = string
}

# RSS Miniflux
variable "rss_miniflux_database_password" {
  description = "RSS Miniflux's database password"
  type = string
}
