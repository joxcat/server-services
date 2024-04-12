variable "mysql_password" {
  description = "Polr's MySQL password"
  type = string
  default = "polr"
}
variable "app_name" {
  description = "Polr's displayed name"
  type = string
  default = "Polr"
}
variable "app_address" {
  description = "Polr's exposed host"
  type = string
}
variable "default_admin_username" {
  description = "Polr's default admin username"
  type = string
}
variable "default_admin_password" {
  description = "Polr's default admin password"
  type = string
}
variable "network" {
  description = "Created container network"
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