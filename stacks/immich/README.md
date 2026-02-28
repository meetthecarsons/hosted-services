# Immich

This directory holds the Docker Compose setup for Immich (photo management).  The compose file is from the official release; see the [Immich docs](https://docs.immich.app/install/docker-compose) for details.

A `.env` file should provide:

```
UPLOAD_LOCATION=/opt/data/library
IMMICH_VERSION=release
DB_PASSWORD=postgres
DB_USERNAME=postgres
DB_DATABASE_NAME=immich
``` 

Change values as needed; the example `.env` in this repo is a good starting point.

To start:

```bash
cd ~/hosted-services/stacks/immich
docker compose up -d
```