#!/bin/sh

# 1. Start Tailscale daemon in background
./tailscaled --state=/var/lib/tailscale/tailscaled.state \
    --socket=/var/run/tailscale/tailscaled.sock \
    --tun=userspace-networking \
    --socks5-server=localhost:1055 \
    --outbound-http-proxy-listen=localhost:1055 &

# 2. Wait for socket
sleep 2

# 3. Bring Tailscale up (Only run once)
./tailscale up \
    --authkey=${TAILSCALE_AUTHKEY} \
    --hostname=${TAILSCALE_HOSTNAME} \
    --advertise-exit-node \
    --accept-dns=true \
    ${TAILSCALE_ADDITIONAL_ARGS}

echo "Tailscale is up. Starting Health Check server..."

# 4. START THE SERVER IN FOREGROUND (No '&')
# This keeps the container 'active' and prevents the restart loop
python3 -m http.server $PORT