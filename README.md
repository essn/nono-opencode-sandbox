# nono-opencode-sandbox

Run [OpenCode](https://opencode.ai) inside a [nono](https://nono.sh) sandbox inside a Docker container.

A hardened sandbox for running OpenCode securely. Combines Docker and nono isolation with defaults for authorization and workspace rollbacks between runs (except build artifacts like `node_modules`). Feel free to tweak to your needs.

## Prerequisites

- Docker and Docker Compose
- An [OpenRouter](https://openrouter.ai), or other provider, API key

## Usage

**Important:** Use [nono's credential injection](https://nono.sh/docs/cli/features/credential-injection) to keep your API key secure and out of the sandboxed environment.

Store your key in your system's credential store, then pass it in:

```sh
# macOS: store key in system keychain, make sure to keep it out of your shell history if you take this approach!
security add-generic-password -s "nono" -a "openrouter" -w "your-api-key"

# Retrieve and run (nono handles the rest securely)
OPENROUTER_API_KEY=$(security find-generic-password -s nono -a openrouter -w) \
  PROJECT_DIR=/path/to/your/project \
  docker compose run --rm --build agent
```

`PROJECT_DIR` defaults to `./project` and mounts at `/workspace`.

## How it works

- **Dockerfile**: Node 22 image with `nono` and `opencode-ai` installed, running as a non-root `agent` user.
- **docker-compose.yaml**: Launches `opencode` via `nono run --rollback` with the `opencode-sandbox` profile. Nono state and OpenCode data persist in named volumes.
- **opencode-sandbox.json**: Nono profile extending `nolabs-ai/opencode`. Filesystem access is limited to the workspace and OpenCode dirs, and network access is limited to `models.dev` plus the OpenRouter proxy.
- **opencode.json**: Points OpenCode's OpenRouter provider at the base URL nono supplies.

The API key is passed as a Docker secret (`/run/secrets/openrouter_key`), not an environment variable. Nono injects it into OpenRouter requests as an `Authorization` header, so the sandboxed agent never sees the key.
