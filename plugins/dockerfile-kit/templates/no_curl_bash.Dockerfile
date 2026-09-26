# Prefer COPY of a pinned install script over curl|bash.
FROM alpine:3.20
COPY scripts/install.sh /tmp/install.sh
RUN chmod +x /tmp/install.sh && /tmp/install.sh && rm /tmp/install.sh
COPY app /app
USER nobody
CMD ["/app"]
