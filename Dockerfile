FROM alpine:3.18.3

# Install necessary networking tools and python for the health check
RUN apk update && apk add --no-cache \
    ca-certificates \
    iptables \
    ip6tables \
    iproute2 \
    python3 \
    wget \
    tar

WORKDIR /tailscale.d

# Define default environment variables
ENV TAILSCALE_VERSION="latest"
ENV TAILSCALE_HOSTNAME="railway-app"
ENV PORT="8080"

# Fetch and install Tailscale binaries
RUN wget https://pkgs.tailscale.com/stable/tailscale_${TAILSCALE_VERSION}_amd64.tgz && \
    tar xzf tailscale_${TAILSCALE_VERSION}_amd64.tgz --strip-components=1 && \
    rm tailscale_${TAILSCALE_VERSION}_amd64.tgz

# Create necessary directories for Tailscale state and sockets
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

COPY start.sh ./start.sh
RUN chmod +x ./start.sh

CMD ["./start.sh"]