FROM caddy:builder-alpine AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddyserver/replace-response

FROM caddy:alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
