FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/generate-cert.sh /usr/local/bin/generate-cert.sh
RUN chmod +x /usr/local/bin/generate-cert.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/generate-cert.sh"]