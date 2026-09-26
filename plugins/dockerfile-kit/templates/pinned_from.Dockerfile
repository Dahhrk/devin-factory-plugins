# Pin immutable tags (no :latest).
FROM python:3.12.6-slim-bookworm
COPY app /app
USER nobody
CMD ["python", "/app"]
