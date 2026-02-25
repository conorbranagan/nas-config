#!/bin/bash
set -e

APP_DIR="${NANOCLAW_HOST_PATH:-/app}"
cd "$APP_DIR"

# Clone on first run, update on subsequent runs
if [ ! -f package.json ]; then
    echo "=== First run: cloning nanoclaw ==="
    git init 2>/dev/null || true
    git remote add origin https://github.com/qwibitai/nanoclaw.git 2>/dev/null || true
    git fetch origin main
    git checkout -f main
    npm install
    npm run build
else
    git pull --ff-only 2>/dev/null || true
    npm install --prefer-offline 2>/dev/null || true
    npm run build 2>/dev/null || true
fi

# Write .env file from environment variables (nanoclaw reads .env directly)
echo "ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}" > "$APP_DIR/.env"

# Ensure data directories exist and are writable by agent containers (node user, uid 1000)
mkdir -p data data/sessions data/ipc store groups/main groups/global
chmod -R 777 data/sessions data/ipc groups

# Ensure shared home is writable by agent containers
SHARED_HOME="${NANOCLAW_HOME:-/mnt/.ix-apps/app_mounts/dockge/stacks/nanoclaw/home}"
mkdir -p "$SHARED_HOME/.gmail-mcp"
chmod -R 777 "$SHARED_HOME"

# Copy default group CLAUDE.md files if missing
if [ ! -f groups/main/CLAUDE.md ] && [ -f groups/main/CLAUDE.md.default ]; then
    cp groups/main/CLAUDE.md.default groups/main/CLAUDE.md
fi
if [ ! -f groups/global/CLAUDE.md ] && [ -f groups/global/CLAUDE.md.default ]; then
    cp groups/global/CLAUDE.md.default groups/global/CLAUDE.md
fi

# Build the nanoclaw-agent image if it doesn't exist on the Docker host
if ! docker image inspect nanoclaw-agent:latest >/dev/null 2>&1; then
    echo "=== Building nanoclaw-agent container image (first run) ==="
    cd "$APP_DIR/container" && bash build.sh && cd "$APP_DIR"
    echo "=== Agent image built successfully ==="
fi

echo "=== NanoClaw starting from $APP_DIR ==="
exec npm start
