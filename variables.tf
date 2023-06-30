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

# Pterodactyl
variable "pterodactyl_app_url" {
  description = "Pterodactyl Public app url"
  type = string
}
variable "pterodactyl_mail" {
  description = "Pterodactyl Platform service email"
  type = string
}
variable "pterodactyl_mariadb_password" {
  description = "Pterodactyl MariaDB password"
  type = string
}
variable "pterodactyl_smtp_host" {
  description = "Pterodactyl SMTP Host"
  type = string
}
variable "pterodactyl_smtp_password" {
  description = "Pterodactyl SMTP Password"
  type = string
}
variable "pterodactyl_smtp_port" {
  description = "Pterodactyl SMTP Port"
  type = string
}
variable "pterodactyl_smtp_username" {
  description = "Pterodactyl SMTP Username"
  type = string
}

# Umami
variable "umami_postgres_password" {
  description = "Umami Postgres database password"
  type = string
}
variable "umami_app_secret" {
  description = "Umami internal app secret"
  type = string
}

# Supabase
variable "supabase_postgres_password" {
  description = "Supabase Postgres password"
  type = string
}
variable "supabase_smtp_host" {
  description = "Supabase smtp host"
  type = string
}
variable "supabase_smtp_port" {
  description = "Supabase smtp port"
  type = string
}
variable "supabase_smtp_user" {
  description = "Supabase SMTP user"
  type = string
}
variable "supabase_smtp_password" {
  description = "Supabase SMTP password"
  type = string
}
variable "supabase_smtp_sender" {
  description = "Supabase sender identity"
  type = string
}
variable "supabase_smtp_admin_email" {
  description = "Supabase Admin's email"
  type = string
}
variable "supabase_studio_public_url" {
  description = "Supabase public URL"
  type = string
}
variable "supabase_jwt_secret" {
  description = "Supabase JWT Secret"
  type = string
}

