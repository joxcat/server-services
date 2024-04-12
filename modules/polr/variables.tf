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
