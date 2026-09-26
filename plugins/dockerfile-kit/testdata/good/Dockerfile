FROM alpine:3.20
COPY app /app
RUN apk add --no-cache ca-certificates
USER nobody
CMD ["/app"]
