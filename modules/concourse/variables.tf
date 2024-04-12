variable "network" {
  description = "Created container network"
  type = string
} 

variable "postgres_password" {
  description = "Concourse postgres password"
  type = string
}

variable "concourse_add_local_user" {
  description = "Concourse ADD_LOCAL_USER env"
  type = string
}
variable "concourse_main_team_local_user" {
  description = "Concourse MAIN_TEAM_LOCAL_USER env"
  type = string
}
