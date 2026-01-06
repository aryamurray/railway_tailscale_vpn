#!/bin/sh

# 1. Start Tailscale daemon
./tailscaled --state=/var/lib/tailscale/tailscaled.state \
    --socket=/var/run/tailscale/tailscaled.sock \
    --tun=userspace-networking \
    --socks5-server=localhost:1055 \
    --outbound-http-proxy-listen=localhost:1055 &

# 2. Start a dummy web server so Railway keeps the container alive (CRITICAL FIX)
if [ -n "$PORT" ]; then
    echo "Starting dummy health check server on port $PORT"
    python3 -m http.server $PORT &
fi

# 3. Bring up the node
# We use 'until' loop as you had it, which is good for reliability
until ./tailscale up \
    --authkey=${TAILSCALE_AUTHKEY} \
    --hostname=${TAILSCALE_HOSTNAME} \
    --advertise-exit-node \
    --accept-dns=true \
    ${TAILSCALE_ADDITIONAL_ARGS}
do
    sleep 0.1
done

echo "Tailscale is up. Sleeping infinity..."
sleep infinity