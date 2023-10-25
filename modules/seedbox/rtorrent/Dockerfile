FROM jesec/rtorrent:master-amd64 as base

FROM alpine

COPY --from=base /usr/bin/rtorrent /usr/bin/rtorrent

USER 1000:1001
ENTRYPOINT ["/usr/bin/rtorrent"]
