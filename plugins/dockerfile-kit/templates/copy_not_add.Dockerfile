# Prefer COPY over ADD for local files (ADD vs COPY secrets chapter).
FROM alpine:3.20
COPY app /app
USER nobody
CMD ["/app"]
