FROM ghcr.io/pterodactyl/wings:latest as base

FROM alpine:latest
COPY --from=base /usr/bin/wings /usr/bin/wings
CMD [ "/usr/bin/wings", "--config", "/etc/pterodactyl/config.yml" ]
