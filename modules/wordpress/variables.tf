variable "network" {
  description = "Created container network"
  type = string
}
variable "resource_prefix" {
  description = "Prefix for every resources"
  type = string
}
variable "mysql_image" {
  description = "MySQL image name"
  type = string
}
variable "database_password" {
  description = "Database password for Wordpress"
  type = string
}
