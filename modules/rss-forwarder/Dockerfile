FROM ghcr.io/morphy2k/rss-forwarder:0.7.0 as src

FROM python:slim
COPY --from=src /usr/local/bin/rss-forwarder /usr/local/bin/rss-forwarder

RUN pip install requests beautifulsoup4
COPY scripts /scripts

CMD ["/bin/rss-forwarder", "/data/config.toml"]
