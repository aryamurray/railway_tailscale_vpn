#!/bin/sh

# Start Tailscale daemon
./tailscaled --state=/var/lib/tailscale/tailscaled.state \
    --socket=/var/run/tailscale/tailscaled.sock \
    --tun=userspace-networking \
    --socks5-server=localhost:1055 \
    --outbound-http-proxy-listen=localhost:1080 \
    --verbose=1 &

sleep 3

# Explicitly disable SNAT and IPv6 acceptance to lighten the netstack load
./tailscale up \
    --authkey="${TAILSCALE_AUTHKEY}" \
    --hostname="${TAILSCALE_HOSTNAME}" \
    --advertise-exit-node \
    --accept-dns=true \
    --accept-routes=false \
    --snat-subnet-routes=false \
    --reset \
    ${TAILSCALE_ADDITIONAL_ARGS}

echo "Tailscale is up. Starting Health Check server..."
exec python3 -m http.server "${PORT:-8080}"