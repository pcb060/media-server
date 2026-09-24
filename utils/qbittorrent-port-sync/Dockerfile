FROM alpine:3.20
RUN apk add --no-cache bash curl python3 docker-cli jq
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]

