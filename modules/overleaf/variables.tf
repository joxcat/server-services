variable "network" {
  description = "Created container network"
  type = string
}
variable "mongo_image" {
  description = "MongoDB docker image"
  type = string
}
variable "redis_image" {
  description = "Redis docker image"
  type = string
}
