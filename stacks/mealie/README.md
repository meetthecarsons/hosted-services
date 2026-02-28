# Mealie

Recipe manager service.  This compose is from a community example and runs the container on port 9925 by default.

Set any environment variables you need in a local `.env` file here; the compose uses `PUID`, `PGID`, `TZ`, `BASE_URL`, etc.

Run with:

```bash
cd ~/hosted-services/stacks/mealie
docker compose up -d
```