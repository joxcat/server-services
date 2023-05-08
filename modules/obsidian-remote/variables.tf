variable "network" {
  description = "Created container network"
  type = string
}
variable "basic_auth_user" {
  description = "Basic auth user"
  type = string
  default = "obsidian"
}
variable "basic_auth_password" {
  description = "Basic auth password"
  type = string
  default = "obsidian"
}
variable "vaults_folder" {
  description = "Vaults host path"
  type = string
}
