#!/bin/bash
set -e

CERT_DIR=/etc/nginx/ssl

if [ ! -f "$CERT_DIR/inception.crt" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$CERT_DIR/inception.key" \
        -out "$CERT_DIR/inception.crt" \
        -subj "/C=FR/ST=PACA/L=Nice/O=42/CN=${DOMAIN_NAME}"
fi

exec nginx -g "daemon off;"