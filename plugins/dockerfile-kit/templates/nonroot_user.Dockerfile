# Drop privileges before final process (no USER root late).
FROM alpine:3.20
RUN adduser -D -H -u 10001 appuser
COPY app /app
USER appuser
CMD ["/app"]
