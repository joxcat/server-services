variable "network" {
  description = "Created container network"
  type = string
}
variable "mariadb_image" {
  description = "MariaDB's container image"
  type = string
}
variable "mariadb_password" {
  description = "MariaDB's root password"
  type = string
}
