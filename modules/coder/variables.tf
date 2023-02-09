variable "network" {
  description = "Created container network"
  type = string
}
variable "postgres_image" {
  description = "Postgres's container image"
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
