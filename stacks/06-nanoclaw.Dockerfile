FROM node:22-slim

# Install Docker CLI, git, and build essentials for native modules
RUN apt-get update && apt-get install -y \
    docker.io \
    git \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
