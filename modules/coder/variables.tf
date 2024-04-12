variable "network" {
  description = "Created container network"
  type = string
}
variable "docker_group_id" {
  description = "Docker's group id"
  type = string
}
variable "postgres_password" {
  description = "Postgres user's password"
}
variable "access_url" {
  description = "Coder access url"
}
variable "wildcard_url" {
  description = "Coder matching wildcard url"
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