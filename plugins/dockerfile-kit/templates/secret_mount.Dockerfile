# BuildKit secret mounts instead of ARG/ENV secrets (SecretsUsedInArgOrEnv).
FROM alpine:3.20
RUN --mount=type=secret,id=aws_key_id,env=AWS_ACCESS_KEY_ID \
    --mount=type=secret,id=aws_secret_key,env=AWS_SECRET_ACCESS_KEY \
    echo "secrets available only for this RUN"
COPY app /app
USER nobody
CMD ["/app"]
