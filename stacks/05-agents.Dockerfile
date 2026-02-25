FROM node:22-slim

RUN apt-get update && apt-get install -y git docker.io curl && rm -rf /var/lib/apt/lists/*

# Claude Code (native install)
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/root/.local/bin:${PATH}"

# OpenAI Codex CLI
RUN npm install -g @openai/codex

# Nanoclaw shortcut
RUN ln -sf /host/mnt/.ix-apps/app_mounts/dockge/stacks/nanoclaw/app /nanoclaw
RUN cat >> /root/.bashrc <<'ALIASES'
nanoclaw() {
  HOME=/mnt/.ix-apps/app_mounts/dockge/stacks/nanoclaw/home \
  CLAUDE_CONFIG_DIR=/root/.claude \
  claude --project-dir /nanoclaw "$@"
}
nc() { nanoclaw "$@"; }
ALIASES

WORKDIR /workspace
CMD ["sleep", "infinity"]
