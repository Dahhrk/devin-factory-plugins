# Good fixture: pinned tag, COPY, apt cleanup, non-root, secret mount, no curl|bash.
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
COPY app /app
RUN --mount=type=secret,id=token cat /run/secrets/token >/dev/null
# ARG NODE_VERSION is not a secret key name
ARG NODE_VERSION=20
USER nobody
CMD ["/app"]
