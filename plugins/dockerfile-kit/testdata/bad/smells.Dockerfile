# Intentional smells for dockerfile-rg-gate (not product).
FROM ubuntu:latest
ARG AWS_SECRET_ACCESS_KEY
ENV DB_PASSWORD=changeme
ADD https://example.com/secrets.tar.gz /tmp/secrets/
ADD id_rsa /root/.ssh/id_rsa
RUN apt-get update && apt-get install -y curl
USER root
RUN curl -fsSL https://example.com/install.sh | bash
CMD ["sleep", "infinity"]
