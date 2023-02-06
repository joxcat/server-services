variable "network" {
  description = "Created container network"
  type = string
}
variable "postgres_image" {
  description = "Postgres Docker Image"
  type = string
}
variable "database_password" {
  description = "Database password"
  type = string
}
