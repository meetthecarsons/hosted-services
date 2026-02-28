# Windmill

This directory contains the Docker Compose file for Windmill (server + workers).  It is configured to use a local PostgreSQL container by default.

Customize environment variables and image via a `.env` file if necessary.  The stack exposes port 8000 for the server.

Bring it up with:

```bash
cd ~/hosted-services/stacks/windmill
docker compose up -d
```