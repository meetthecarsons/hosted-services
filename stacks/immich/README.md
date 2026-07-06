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

## Hardware acceleration (Intel Quick Sync)

Both containers already pass through `/dev/dri` for the host's Intel iGPU:

- `immich-machine-learning` uses the `-openvino` image tag, which picks up
  hw-accelerated facial recognition / smart search (CLIP) automatically once
  the container starts — no further settings needed.
- `immich-server` still requires an explicit runtime setting (stored in the
  DB, not the compose file): **Administration -> Settings -> Video
  Transcoding Settings -> Hardware Acceleration -> Quick Sync (QSV)**, then
  re-encode/restart any jobs that should use it.

If either container can't access `/dev/dri` (permission denied in logs),
confirm the host user running Docker is in the `video`/`render` group.
