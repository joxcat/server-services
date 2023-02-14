variable "network" {
  description = "Created container network"
  type = string
}
variable "mysql_image" {
  description = "MySQL container's image"
  type = string
}
variable "mysql_password" {
  description = "MySQL database's password"
  type = string
}
variable "public_url" {
  description = "Public facing url"
  type = string
}
variable "smtp_host" {
  description = "SMTP server host"
  type = string
}
variable "smtp_port" {
  description = "SMTP server port"
  type = number
  default = 587
}
variable "smtp_secure" {
  description = "SMTP use tls"
  type = bool
  default = true
}
variable "smtp_user" {
  description = "SMTP user"
  type = string
}
variable "smtp_password" {
  description = "SMTP password"
  type = string
}
variable "smtp_from" {
  description = "SMTP From value"
  type = string
}
