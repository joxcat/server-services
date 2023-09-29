FROM caddy:builder-alpine AS builder

WORKDIR /build
RUN xcaddy build master \
    --with github.com/caddy-dns/cloudflare@latest \
    --with github.com/caddyserver/replace-response@latest

FROM caddy:alpine
COPY --from=builder /build/caddy /usr/bin/caddy
