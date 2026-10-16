FROM node:22-bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates git jq \
  && rm -rf /var/lib/apt/lists/*

# Install nono, then make sure the binary is on PATH for the non-root user.
RUN curl -fsSL https://nono.sh/install.sh | sh \
  && for p in "$(command -v nono || true)" /root/.local/bin/nono /root/.cargo/bin/nono; do \
  if [ -n "$p" ] && [ -x "$p" ]; then \
  [ "$p" = /usr/local/bin/nono ] || install -m 0755 "$p" /usr/local/bin/nono; \
  break; \
  fi; \
  done \
  && nono --version

# OpenCode (verify package name against current OpenCode docs)
RUN npm i -g opencode-ai

RUN useradd -m -s /bin/bash agent \
  && mkdir -p /home/agent/.local/state/nono /home/agent/.config/nono/profiles /workspace \
  /home/agent/.local/share/opencode /home/agent/.local/state/opencode \
  /home/agent/.cache/opencode /home/agent/.config/opencode \
  && chown -R agent:agent /home/agent /workspace

COPY --chown=agent:agent opencode-sandbox.json /home/agent/.config/nono/profiles/opencode-sandbox.json

USER agent
RUN nono pull nolabs-ai/opencode
WORKDIR /workspace
