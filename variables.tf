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

# Wordpress Vic
variable "wordpress_vic_database_password" {
  description = "Wordpress's database password"
  type = string
}

# SearX
variable "searx_host" {
  description = "SearX's host"
  type = string
}

# Code-server
variable "code_server_git_name" {
  description = "Code Server Git name"
  type = string
}
variable "code_server_git_email" {
  description = "Code Server Git Email"
  type = string
}

# Coder
variable "coder_postgres_password" {
  description = "Coder's postgres password"
  type = string
} 
variable "coder_access_url" {
  description = "Coder's access url"
  type = string
}
variable "coder_wildcard_url" {
  description = "Coder's wildcard matching url"
  type = string
}

# Ghost
variable "ghost_mysql_password" {
  description = "Ghost MySQL database's password"
  type = string
}
variable "ghost_public_url" {
  description = "Ghost public facing url"
  type = string
}
variable "ghost_smtp_host" {
  description = "Ghost SMTP server host"
  type = string
}
variable "ghost_smtp_user" {
  description = "Ghost SMTP user"
  type = string
}
variable "ghost_smtp_password" {
  description = "Ghost SMTP password"
  type = string
}
variable "ghost_smtp_from" {
  description = "Ghost SMTP From value"
  type = string
}

