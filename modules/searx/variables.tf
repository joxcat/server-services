variable "network" {
  description = "Created container network"
  type = string
}
variable "redis_image" {
  description = "Redis image"
  type = string
}
variable "host" {
  description = "SearX's domain name"
  type = string
}
