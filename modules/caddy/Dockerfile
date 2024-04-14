FROM caddy:builder-alpine AS builder

WORKDIR /build
RUN xcaddy build v2.7.6 \
    --with github.com/caddy-dns/cloudflare@latest \
    --with github.com/caddyserver/replace-response@latest

FROM caddy:alpine
COPY --from=builder /build/caddy /usr/bin/caddy
