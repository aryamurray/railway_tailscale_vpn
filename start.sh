#!/bin/sh

# 1. Start Tailscale daemon in background
# Split proxy ports: SOCKS5 on 1055, HTTP on 1080 to avoid socket contention
./tailscaled --state=/var/lib/tailscale/tailscaled.state \
    --socket=/var/run/tailscale/tailscaled.sock \
    --tun=userspace-networking \
    --socks5-server=localhost:1055 \
    --outbound-http-proxy-listen=localhost:1080 &

# 2. Wait for socket to be ready
sleep 3

# 3. Bring Tailscale up
# Added --accept-routes=false to reduce netstack overhead 
# Added --reset to clear any stale state causing 'address already in use' errors
./tailscale up \
    --authkey="${TAILSCALE_AUTHKEY}" \
    --hostname="${TAILSCALE_HOSTNAME}" \
    --advertise-exit-node \
    --accept-dns=true \
    --accept-routes=false \
    --reset \
    ${TAILSCALE_ADDITIONAL_ARGS}

echo "Tailscale is up. Starting Health Check server on port ${PORT}..."

# 4. START THE SERVER IN FOREGROUND
# Using 'exec' to ensure signals are passed correctly to the python process
exec python3 -m http.server "${PORT:-8080}"