variable "network" {
  description = "Created container network"
  type = string
}
variable "mariadb_image" {
  description = "MariaDB's container image"
  type = string
}
variable "redis_image" {
  description = "Redis's container image"
  type = string
}
variable "app_url" {
  description = "Public app url"
  type = string
}
variable "mail" {
  description = "Platform service email"
  type = string
}
variable "mariadb_password" {
  description = "MariaDB password"
  type = string
}
variable "smtp_host" {
  description = "SMTP Host"
  type = string
}
variable "smtp_password" {
  description = "SMTP Password"
  type = string
}
variable "smtp_port" {
  description = "SMTP Port"
  type = string
}
variable "smtp_username" {
  description = "SMTP Username"
  type = string
}

