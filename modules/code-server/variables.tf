variable "network" {
  description = "Created container network"
  type = string
}
variable "git_name" {
  description = "Container's Git name"
  type = string
}
variable "git_email" {
  description = "Container's Git email"
  type = string
}
variable "user_id" {
  description = "User linux's UID"
  type = string
  default = "1000"
}
variable "user_group" {
  description = "User linux's GID"
  type = string
  default = "1000"
}
variable "memory_limit" {
  description = "Max allocated RAM to the editor"
  type = number
  default = 16384
}
