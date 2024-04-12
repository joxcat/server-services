variable "network" {
  description = "Created container network"
  type = string
} 

variable "postgres_password" {
  description = "Concourse postgres password"
  type = string
}

variable "concourse_add_local_user" {
  description = "Concourse ADD_LOCAL_USER env"
  type = string
}
variable "concourse_main_team_local_user" {
  description = "Concourse MAIN_TEAM_LOCAL_USER env"
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