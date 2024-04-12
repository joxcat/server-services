variable "network" {
  description = "Created container network"
  type = string
}
variable "postgres_password" {
  description = "Postgres database password"
  type = string
}
variable "app_secret" {
  description = "Random string to be used as an app secret"
  type = string
}

# SFTP
variable "sftp_path" {
  description = "SFTP path"
  type = string
}
variable "sftp_host" {
  description = "SFTP host"
  type = string
}
variable "sftp_port" {
  description = "SFTP port"
  type = string
}
variable "sftp_user" {
  description = "SFTP Basic Auth username"
  type = string
}
variable "sftp_password" {
  description = "SFTP Basic Auth password"
  type = string
}