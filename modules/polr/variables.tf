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
variable "mysql_image" {
  description = "MySQL docker image"
  type = string
}
variable "network" {
  description = "Created container network"
  type = string
}
