# steward

Each subdirectory represents a host running [stack-agent](https://github.com/rcarson/stack-agent), a lightweight daemon that watches this repository for changes and automatically reconciles running Docker Compose stacks.

## How it works

On each poll interval, stack-agent fetches the current HEAD of this repo. If it has changed, it sparse-checkouts the configured stack subdirectory and runs `docker compose up -d --remove-orphans`. Failures in one stack never block the others.

## Directory structure

```
steward/
  <hostname>/
    compose.yaml   # deploys stack-agent itself
    config.yml     # which stacks to watch and where to find their env files
    config/        # host-local env files — one per stack (gitignored, secrets)
    data/          # stack-agent state (gitignored)
```

## Bootstrapping a new host

**1. Clone the repo and navigate to the host directory.**

```bash
git clone https://github.com/meetthecarsons/hosted-services.git
cd hosted-services/steward/<hostname>
```

**2. Create env files for each stack.**

```bash
mkdir -p config
# Use the .env.example from each stack as a template
cp ../../stacks/<name>/.env.example config/<name>.env
# Edit with real values
vi config/<name>.env
chmod 600 config/*.env
```

**3. Create the env file for stack-agent itself (the GitHub token).**

```bash
echo "HOST_SERVICES_TOKEN=<your-token>" > .env
chmod 600 .env
```

**4. Start steward.**

```bash
docker compose up -d
```

**5. Verify it's running.**

```bash
docker logs -f stack-agent
```

## Adding a new host

1. Create a new directory under `steward/` named after the host.
2. Copy `compose.yaml` from an existing host directory.
3. Write a `config.yml` listing the stacks for that host.
4. Follow the bootstrapping steps above on the host.
