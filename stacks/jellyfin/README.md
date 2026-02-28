Exposing Jellyfin via Caddy (Let's Encrypt)

> **Note:** this directory has been moved to `stacks/jellyfin` in the repository layout.

Overview
- This folder contains a docker-compose setup for `jellyfin` + `caddy` as a reverse-proxy.
- `caddy` will obtain TLS certificates automatically from Let's Encrypt for the hostname you configure in the `Caddyfile`.

Preconditions
- You must own a DNS name and be able to create an A record for the hostname you choose (e.g. `jellyfin.yourdomain.com`) that points to your home's public IP.
- Your router must forward ports `80` and `443` to the machine running this compose — or, see the section below if you want to expose Caddy on non-standard host ports.

Files
- `docker-compose.yaml` - services for `jellyfin` and `caddy`.
- `Caddyfile` - reverse-proxy configuration; replace `YOUR_DOMAIN` with your host.

Quick start
1. Edit `Caddyfile` and replace `YOUR_DOMAIN` with your DNS name (e.g. `jellyfin.example.com`).
2. Ensure DNS A record for that name points to your public IP.
3. Forward router ports `80->host:80` and `443->host:443` where this compose will run.
4. From this folder run:

```bash
docker compose up -d
```

5. Visit `https://YOUR_DOMAIN` and complete Jellyfin setup (create admin account, media libraries).
6. In Jellyfin admin settings, set the "Public HTTP" URL to `https://YOUR_DOMAIN` so client devices register correctly.

Security recommendations (Roku-compatible)
- Do NOT use HTTP Basic or reverse-proxy SSO for the Jellyfin hostname; Roku devices need plain HTTPS with regular Jellyfin credentials.
- Create separate non-admin accounts for each user; do not share admin.
- Enable and enforce strong passwords; Roku users will enter the password on the device.
- Disable anonymous or guest access.
- Limit simultaneous streams per account and set conservative remote bitrate default (to protect your upload).
- Run `fail2ban` on the host to watch Jellyfin logs and ban repeated failed login attempts (see notes below).

Bandwidth guidance
- Your upstream (~30 Mbps) is enough for ~2 concurrent 1080p direct-play streams (assuming ~6-8 Mbps each).
- Encourage direct-play by using compatible codecs/containers on client devices to avoid server transcoding.
- If transcoding is needed, ensure the Jellyfin host has sufficient CPU/GPU for the expected load.

Adding protections (recommended next steps)
- Consider placing Cloudflare in front of the domain for WAF/rate-limiting (optional). If you later want Cloudflare Tunnel, you can switch from this setup to cloudflared to avoid router port-forwards.
- Configure `fail2ban` or `crowdsec` to parse Jellyfin logs and ban attackers.

If you want, I can:
- Add a `fail2ban` container or host config example monitoring Jellyfin logs.
- Add bandwidth/stream limit configuration for Jellyfin and sample user creation scripts.
- Prepare a Cloudflare Tunnel variant to avoid router changes (requires a Cloudflare account and domain).

Non-standard host ports (optional)
- If you prefer exposing Caddy on non-standard host ports (for example host `8095` for HTTP and `8096` for HTTPS) the compose in this folder maps `8095:80` and `8096:443`.
- Important: Let's Encrypt ACME usually requires public ports `80` and `443` to reach your server for HTTP-01 or TLS-ALPN-01 challenges. If you put Caddy on non-standard host ports you must configure your router to forward public port `80` -> host `8095` and public port `443` -> host `8096` so Let's Encrypt can complete validation.
- Alternative: use a DNS challenge (Cloudflare, Route53, etc.) to obtain certs without exposing `80`/`443`, or use Cloudflare Tunnel to avoid port-forwards entirely.
