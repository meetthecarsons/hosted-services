# Infisical (self-host) stack

Quick scaffold to run Infisical locally with Docker Compose.

1. Copy the example env and edit values:

   cp stacks/infisical/.env.example stacks/infisical/.env

2. Edit `stacks/infisical/.env` and set strong secrets (JWT/Master keys).

3. Start the stack:

```bash
docker compose -f stacks/infisical/docker-compose.yaml --env-file stacks/infisical/.env up -d
```

4. Visit the UI at `http://localhost:3000` and the API at `http://localhost:8080`.

Notes:
- Images referenced (ghcr.io/infisical/...) are placeholders; verify the official image names/tags before production use.
- Use an external managed Postgres for production and enable backups.
- Keep `INFISICAL_MASTER_KEY` and `INFISICAL_JWT_SECRET` safe — losing them may make secrets unrecoverable.

Reverse-proxy (Caddy) snippet example:

```
infisical.example.com {
  route /api/* {
    reverse_proxy 127.0.0.1:8080
  }
  route /* {
    reverse_proxy 127.0.0.1:3000
  }
  tls you@example.com
}
```

Replace `infisical.example.com` and TLS email as appropriate. For production, run Postgres and MinIO outside ephemeral containers and secure networking.
