variable "network" {
  description = "Created container network"
  type = string
}
# Secrets
variable "postgres_password" {
  description = "Postgres Password"
  type = string
}
variable "jwt_secret" {
  description = "Your super JWT Token at least 32 char long"
  type = string
}
variable "anon_key" {
  description = "?"
  type = string
  default = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICAgInJvbGUiOiAiYW5vbiIsCiAgICAiaXNzIjogInN1cGFiYXNlIiwKICAgICJpYXQiOiAxNjg4MjQ4ODAwLAogICAgImV4cCI6IDE4NDYxMDE2MDAKfQ.3CNvP8ZffwTRdqyqbYGfUXTtPntU82sSuiYsjY_vv1k"
}
variable "service_role_key" {
  description = "?"
  type = string
  default = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICAgInJvbGUiOiAic2VydmljZV9yb2xlIiwKICAgICJpc3MiOiAic3VwYWJhc2UiLAogICAgImlhdCI6IDE2ODgyNDg4MDAsCiAgICAiZXhwIjogMTg0NjEwMTYwMAp9.A1t7YKV7Bf72NugtutV5Nk7ewRXIzFknKinltgJyH9o"
}
# API
# - Configuration for PostgREST
variable "postgrest_db_schema" {
  description = "PostgREST DB schema"
  type = string
  default = "public,storage,graphql_public"
}
# Auth
# - Configuration for the GoTrue authentication server
## General
variable "site_url" {
  description = ""
  type = string
  default = "http://localhost:3000"
}
variable "jwt_expiry" {
  description = "Timeout of the JWT token"
  type = string
  default = "3000"
}
variable "disable_signup" {
  description = "Allow or not creation of user accounts"
  type = string
  default = "true"
}
variable "api_external_url" {
  description = "Public url of the API"
  type = string
  default = "http://localhost:8000"
}

## Email auth
variable "enable_email_signup" {
  description = "Allow user to register using email"
  type = string
  default = "true"
}
variable "enable_email_autoconfirm" {
  description = "Do not validate user email"
  type = string
  default = "false"
}
variable "smtp_admin_email" {
  description = "SMTP Admin mail"
  type = string
}
variable "smtp_host" {
  description = "SMTP server host"
  type = string
}
variable "smtp_port" {
  description = "SMTP server port"
  type = string
}
variable "smtp_user" {
  description = "SMTP username"
  type = string
}
variable "smtp_password" {
  description = "SMTP password"
  type = string
}
variable "smtp_sender" {
  description = "SMTP sender name"
  type = string
}

## Phone auth
variable "enable_phone_signup" {
  description = "Allow user to signup using phone"
  type = string
  default = "false"
}
variable "enable_phone_autoconfirm" {
  description = "Do not validate user phone"
  type = string
  default = "false"
}

# Studio
# - Configuration for the Dashboard
variable "studio_public_url" {
  description = "Public url of Supabase Studio"
  type = string
}

