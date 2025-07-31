# Proxy Server

Centralized nginx reverse proxy for routing multiple domains to different Docker containers.

## Setup

1. Ensure the proxy network exists:
   ```bash
   docker network create proxy-network
   ```

2. Deploy the proxy:
   ```bash
   docker compose up -d
   ```

## Adding a New Site

1. Create a new config file in `nginx/conf.d/sitename.conf`
2. Ensure the target container is on the `proxy-network`
3. Reload nginx: `docker exec main-proxy nginx -s reload`

## SSL Certificates

Certificates are managed via certbot and mounted from `/etc/letsencrypt` on the host.
