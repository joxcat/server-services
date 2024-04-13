# SFTP
variable "instance_name" {
  type = string
  description = "Docker container name"
}
variable "sftp_host" {
  type = string
  description = "SFTP host"
}
variable "sftp_port" {
  type = string
  description = "SFTP port"
}
variable "sftp_user" {
  type = string
  description = "SFTP user"
}
variable "sftp_password" {
  type = string
  description = "SFTP password"
  sensitive = true
}
variable "sftp_base_path" {
  type = string
  description = "SFTP base path"
}