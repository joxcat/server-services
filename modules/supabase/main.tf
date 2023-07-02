terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Ported from docker-compose.yml
# on 2023-07-02 from https://github.com/supabase/supabase/blob/185034b4ffe3bf43fa137ec9870ebc166a4c2f1d/docker/docker-compose.yml 

resource "docker_network" "supabase" {
  name = "internal_supabase"
}

resource "docker_image" "supabase_studio" {
  name = "supabase/studio:20230621-7a24ddd"
}
resource "docker_image" "supabase_kong" {
  name = "kong:2.8.1"
}
resource "docker_image" "supabase_gotrue" {
  name = "supabase/gotrue:v2.62.1"
}
resource "docker_image" "supabase_postgrest" {
  name = "postgrest/postgrest:v10.1.2"
}
resource "docker_image" "supabase_realtime" {
  name = "supabase/realtime:v2.10.1"
}
resource "docker_image" "supabase_storage" {
  name = "supabase/storage-api:v0.40.4"
}
resource "docker_image" "supabase_imgproxy" {
  name = "darthsim/imgproxy:v3.8.0"
}
resource "docker_image" "supabase_meta" {
  name = "supabase/postgres-meta:v0.66.3"
}
resource "docker_image" "supabase_fn" {
  name = "supabase/edge-runtime:v1.5.2"
}
resource "docker_image" "supabase_db" {
  name = "supabase/postgres:15.1.0.90"
}

resource "docker_container" "supabase_studio" {
  name = "supabase-studio"
  hostname = "studio"
  image = docker_image.supabase_studio.image_id
  restart = "unless-stopped"
  
  healthcheck {
    test = [
      "CMD", 
      "node", 
      "-e", 
      "require('http').get('http://localhost:3000/api/profile', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"
    ]
    timeout = "5s"
    interval = "5s"
    retries = "3"
  }
    
  env = [
    "STUDIO_PG_META_URL=http://meta:8080",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "DEFAULT_ORGANIZATION_NAME=Default Organization",
    "DEFAULT_PROJECT_NAME=Default Project",
    "SUPABASE_URL=http://kong:8000",
    "SUPABASE_PUBLIC_URL=${var.studio_public_url}",
    "SUPABASE_ANON_KEY=${var.anon_key}",
    "SUPABASE_SERVICE_KEY=${var.service_role_key}"
  ]

  networks_advanced {
    name = docker_network.supabase.id
  }
  # Inner port = 3000/tcp
  networks_advanced {
    name = var.network
  }

  depends_on = [
    docker_image.supabase_studio,
    docker_network.supabase,
  ]
}

resource "docker_container" "supabase_kong" {
  name = "supabase-kong"
  hostname = "kong"
  image = docker_image.supabase_kong.image_id
  restart = "unless-stopped"

  env = [
    "KONG_DATABASE=off",
    "KONG_DECLARATIVE_CONFIG=/var/lib/kong/kong.yml",
    # https://github.com/supabase/cli/issues/14
    "KONG_DNS_ORDER=LAST,A,CNAME",
    "KONG_PLUGINS=request-transformer,cors,key-auth,acl",
    "KONG_NGINX_PROXY_PROXY_BUFFER_SIZE=160k",
    "KONG_NGINX_PROXY_PROXY_BUFFERS=64 160k",
  ]

  # https://github.com/supabase/supabase/issues/12661
  volumes {
    host_path = abspath("./modules/supabase/kong.yml")
    container_path = "/var/lib/kong/kong.yml"
    read_only = true
  }

  networks_advanced {
    name = docker_network.supabase.id
  }
  # Inner port 8000
  networks_advanced {
    name = var.network
  }

  depends_on = [
    docker_image.supabase_kong,
    docker_network.supabase,
  ]
}

resource "docker_container" "supabase_auth" {
  name = "supabase-auth"
  hostname = "auth"
  image = docker_image.supabase_gotrue.image_id
  restart = "unless-stopped"

  healthcheck {
    test = [
      "CMD",
      "wget",
      "--no-verbose",
      "--tries=1",
      "--spider",
      "http://localhost:9999/health",
    ]
    timeout = "5s"
    interval = "5s"
    retries = 3
  }

  env = [
    "GOTRUE_API_HOST=0.0.0.0",
    "GOTRUE_API_PORT=9999",
    "API_EXTERNAL_URL=${var.api_external_url}",
    "GOTRUE_DB_DRIVER=postgres",
    "GOTRUE_DB_DATABASE_URL=postgres://supabase_auth_admin:${var.postgres_password}@db:5432/postgres",
    "GOTRUE_SITE_URL=${var.site_url}",
    "GOTRUE_URI_ALLOW_LIST=",
    "GOTRUE_DISABLE_SIGNUP=${var.disable_signup}",
    "GOTRUE_JWT_ADMIN_ROLES=service_role",
    "GOTRUE_JWT_AUD=authenticated",
    "GOTRUE_JWT_DEFAULT_GROUP_NAME=authenticated",
    "GOTRUE_JWT_EXP=${var.jwt_expiry}",
    "GOTRUE_JWT_SECRET=${var.jwt_secret}",
    "GOTRUE_EXTERNAL_EMAIL_ENABLED=${var.enable_email_signup}",
    "GOTRUE_MAILER_AUTOCONFIRM=${var.enable_email_autoconfirm}",
    "GOTRUE_SMTP_ADMIN_EMAIL=${var.smtp_admin_email}",
    "GOTRUE_SMTP_HOST=${var.smtp_host}",
    "GOTRUE_SMTP_PORT=${var.smtp_port}",
    "GOTRUE_SMTP_USER=${var.smtp_user}",
    "GOTRUE_SMTP_PASS=${var.smtp_password}",
    "GOTRUE_SMTP_SENDER_NAME=${var.smtp_sender}",
    "GOTRUE_EXTERNAL_PHONE_ENABLED=${var.enable_phone_signup}",
    "GOTRUE_SMS_AUTOCONFIRM=${var.enable_phone_autoconfirm}",
    "MFA_ENABLED=false"
  ]
  
  networks_advanced {
    name = docker_network.supabase.id
  }

  depends_on = [
    docker_image.supabase_gotrue,
    docker_network.supabase,
    docker_container.supabase_db,
  ]
}

resource docker_container "supabase_rest" {
  name = "supabase-rest"
  hostname = "rest"
  image = docker_image.supabase_postgrest.image_id
  restart = "unless-stopped"

  env = [
    "PGRST_DB_URI=postgres://authenticator:${var.postgres_password}@db:5432/postgres",
    "PGRST_DB_ANON_ROLE=anon",
    "PGRST_JWT_SECRET=${var.jwt_secret}",
    "PGRST_DB_USE_LEGACY_GUCS=false"
  ]

  networks_advanced {
    name = docker_network.supabase.id
  }

  depends_on = [
    docker_network.supabase,
    docker_container.supabase_db
  ]
}

resource docker_container "supabase_realtime" {
  name = "supabase-realtime"
  hostname = "realtime"
  image = docker_image.supabase_realtime.image_id
  restart = "unless-stopped"

  healthcheck {
    test = [
      "CMD",
      "bash",
      "-c",
      "printf \\0 > /dev/tcp/localhost/4000"
    ]
    timeout = "5s"
    interval = "5s"
    retries = 3
  }

  env = [
    "PORT=4000",
    "DB_HOST=db",
    "DB_PORT=5432",
    "DB_USER=supabase_admin",
    "DB_PASSWORD=${var.postgres_password}",
    "DB_NAME=postgres",
    "DB_AFTER_CONNECT_QUERY=SET search_path TO _realtime",
    "DB_ENC_KEY=supabaserealtime",
    "API_JWT_SECRET=${var.jwt_secret}",
    "FLY_ALLOC_ID=fly123",
    "FLY_APP_NAME=realtime",
    "SECRET_KEY_BASE=UpNVntn3cDxHJpq99YMc1T1AQgQpc8kfYTuRgBiYa15BLrx8etQoXz3gZv1/u2oq",
    "ERL_AFLAGS=-proto_dist inet_tcp",
    "ENABLE_TAILSCALE=false",
    "DNS_NODES=''"
  ]

  command = ["sh", "-c", "/app/bin/migrate && /app/bin/realtime eval 'Realtime.Release.seeds(Realtime.Repo)' && /app/bin/server"]
  
  networks_advanced {
    name = docker_network.supabase.id
  }

  depends_on = [
    docker_network.supabase,
    docker_container.supabase_db
  ]
}

resource docker_container "supabase_storage" {
  name = "supabase-storage"
  hostname = "storage"
  image = docker_image.supabase_storage.image_id
  restart = "unless-stopped"

  healthcheck {
    test = [
      "CMD",
      "wget",
      "--no-verbose",
      "--tries=1",
      "--spider",
      "http://localhost:5000/status"
    ]
    timeout = "5s"
    interval = "5s"
    retries = 3
  }

  env = [
    "ANON_KEY=${var.anon_key}",
    "SERVICE_KEY=${var.service_role_key}",
    "POSTGREST_URL=http://rest:3000",
    "PGRST_JWT_SECRET=${var.jwt_secret}",
    "DATABASE_URL=postgres://supabase_storage_admin:${var.postgres_password}@db:5432/postgres",
    "FILE_SIZE_LIMIT=52428800",
    "STORAGE_BACKEND=file",
    "FILE_STORAGE_BACKEND_PATH=/var/lib/storage",
    "TENANT_ID=stub",
    # TODO: https://github.com/supabase/storage-api/issues/55
    "REGION=stub",
    "GLOBAL_S3_BUCKET=stub",
    "ENABLE_IMAGE_TRANSFORMATION=true",
    "IMGPROXY_URL=http://imgproxy:5001"
  ]

  volumes {
    host_path = "/var/local/docker/supabase/storage"
    container_path = "/var/lib/storage"
  }

  networks_advanced {
    name = docker_network.supabase.id
  }

  depends_on = [
    docker_network.supabase,
    docker_container.supabase_db,
    docker_container.supabase_rest,
    docker_container.supabase_imgproxy
  ]
}

resource docker_container "supabase_imgproxy" {
  name = "supabase-imgproxy"
  hostname = "imgproxy"
  image = docker_image.supabase_imgproxy.image_id
  restart = "unless-stopped"
  
  healthcheck {
    test = [
      "CMD",
      "imgproxy",
      "health",
    ]
    timeout = "5s"
    interval = "5s"
    retries = 3
  }

  env = [
    "IMGPROXY_BIND=:5001",
    "IMGPROXY_LOCAL_FILESYSTEM_ROOT=/",
    "IMGPROXY_USE_ETAG=true",
    "IMGPROXY_ENABLE_WEBP_DETECTION=true"
  ]

  volumes {
    host_path = "/var/local/docker/supabase/storage"
    container_path = "/var/lib/storage"
  }

  networks_advanced {
    name = docker_network.supabase.id
  }

  depends_on = [
    docker_network.supabase,
  ]
}

resource docker_container "supabase_meta" {
  name = "supabase-meta"
  hostname = "meta"
  image = docker_image.supabase_meta.image_id
  restart = "unless-stopped"

  env = [
    "PG_META_PORT=8080",
    "PG_META_DB_HOST=db",
    "PG_META_DB_PORT=5432",
    "PG_META_DB_NAME=postgres",
    "PG_META_DB_USER=supabase_admin",
    "PG_META_DB_PASSWORD=${var.postgres_password}"
  ]

  networks_advanced {
    name = docker_network.supabase.id
  }

  depends_on = [
    docker_network.supabase,
    docker_container.supabase_db,
  ]
}

resource docker_container "supabase_functions" {
  name = "supabase-functions"
  hostname = "functions"
  image = docker_image.supabase_fn.image_id
  restart = "unless-stopped"

  env = [
    "JWT_SECRET=${var.jwt_secret}",
    "SUPABASE_URL=http://kong:8000",
    "SUPABASE_ANON_KEY=${var.anon_key}",
    "SUPABASE_SERVICE_ROLE_KEY=${var.service_role_key}",
    "SUPABASE_DB_URL=postgresql://supabase_functions_admin:${var.postgres_password}@db:5432/postgres",
    "VERIFY_JWT=false"
  ]

  command = ["start", "--main-service", "/home/deno/functions/main"]

  volumes {
    host_path = abspath("./modules/supabase/functions")
    container_path = "/home/deno/functions"
  }

  networks_advanced {
    name = docker_network.supabase.id
  }

  depends_on = [
    docker_network.supabase,
  ]
}

resource docker_container "supabase_db" {
  name = "supabase-db"
  hostname = "db"
  image = docker_image.supabase_db.image_id
  restart = "unless-stopped"
  
  healthcheck {
    test = [
      "CMD",
      "pg_isready",
      "-U",
      "postgres",
      "-h",
      "localhost"
    ]
    timeout = "5s"
    interval = "5s"
    retries = 10
  }

  env = [
    "POSTGRES_HOST=/var/run/postgresql",
    "PGPORT=5432",
    "POSTGRES_PORT=5432",
    "PGPASSWORD=${var.postgres_password}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "PGDATABASE=postgres",
    "POSTGRES_DB=postgres"
  ]

  command = [
    "postgres",
    "-c",
    "config_file=/etc/postgresql/postgresql.conf",
    "-c",
    "log_min_messages=fatal" # prevents Realtime polling queries from appearing in logs
  ]

  volumes {
    host_path = abspath("./modules/supabase/realtime.sql")
    container_path = "/docker-entrypoint-initdb.d/migrations/99-realtime.sql"
  }

  volumes {
    host_path = abspath("./modules/supabase/webhooks.sql")
    container_path = "/docker-entrypoint-initdb.d/migrations/98-webhooks.sql"
  }

  volumes {
    host_path = abspath("./modules/supabase/roles.sql")
    container_path = "/docker-entrypoint-initdb.d/migrations/99-roles.sql"
  }

  volumes {
    host_path = "/var/local/docker/supabase/database" 
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = docker_network.supabase.id
  }

  depends_on = [
    docker_network.supabase,
  ]
}
