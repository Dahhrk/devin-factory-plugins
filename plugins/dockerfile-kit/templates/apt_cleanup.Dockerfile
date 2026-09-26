# apt update/install with lists cleanup on the same RUN (same physical line for rg bar).
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
COPY app /app
USER nobody
CMD ["/app"]
