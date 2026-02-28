# OpenNotebook

This folder contains a two‑service compose: `surrealdb` and `open_notebook`.

No special configuration is required; `open_notebook` listens on port 8502.  Builds use the `lfnovo/open_notebook` image.

To run:

```bash
cd ~/hosted-services/stacks/opennotebook
docker compose up -d
```