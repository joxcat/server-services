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