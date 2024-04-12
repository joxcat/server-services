variable "network" {
  description = "Created container network"
  type = string
}
variable "postgres_password" {
  description = "Postgres database password"
  type = string
}
variable "app_secret" {
  description = "Random string to be used as an app secret"
  type = string
}
