Accessing Jellyfin on the tailnet and local LAN

> **Note:** this directory has been moved to `stacks/jellyfin` in the repository layout.
>
> Historically the stack used Caddy with Let's Encrypt to expose Jellyfin to the
> public Internet.  In the current deployment we no longer publish it on the
> WAN; remote clients connect over Tailscale and local clients use an internal
> reverse proxy.  The old Internet‑exposure instructions remain below for
> reference but can be ignored unless you intentionally want to re‑enable
> public access.

Overview
- This folder contains a docker-compose setup for `jellyfin`, optionally
  with `caddy` as a reverse-proxy when Internet exposure is required.

Files
- `docker-compose.yaml` - services for `jellyfin` (plus `tailscale`).
- `Caddyfile` - **legacy** reverse-proxy configuration; the active proxy lives
  in `stacks/reverse-proxy` now.  You can remove this file if you don’t need
  the old configuration.

Quick start (tailnet/local use)
1. Bring up the stack from this directory:

```bash
docker compose up -d
```

2. Authenticate the `tailscale` service (see Tailnet access section below).
3. Points clients either at the internal proxy hostnames or directly to
   `ds-s-01.lan.internal:8096` while they remain on the LAN.
4. No router port-forwards are required unless you later decide to expose
   the service publicly.

The legacy "Expose via Caddy/Let's Encrypt" instructions are further down
for historical curiosity.

---

### Tailnet access (optional)

If you want Jellyfin accessible only on your Tailscale mesh, a `tailscale` service is included in the compose. After bringing the stack up:

```sh
# authenticate the host and give it a magic-dns name (e.g. jelly)
docker exec tailscale tailscale up --authkey=tskey-... --hostname=jelly

# optionally expose the Jellyfin port on the tailnet
docker exec tailscale tailscale serve jelly.<your-tailnet>.ts.net=8096
```

Clients on the tailnet can then reach the server as `https://jelly.<your-tailnet>.ts.net` without opening public ports.  This works equally well from a laptop, phone, or a Tailscale‑capable TV – once the device is logged into your tailnet the app will talk directly to the server.  See the main repo README for general tailscale guidance.

---

### Internal network & reverse proxy

This service now joins the shared `internal` network, which is automatically
created when you deploy the proxy stack.  The proxy itself owns the network,
so there is no need for a separate `internal` stack or manual network command.
Remove the `ports:` mappings above, since all traffic will be routed by
hostname through the proxy.

To deploy the proxy and network:

```sh
cd stacks/reverse-proxy
# brings up Caddy and simultaneously creates the `internal` network
docker compose up -d
```

Configure the proxy's `Caddyfile` (or equivalent) with entries for each
service, e.g. `jelly.svc.internal` → `jellyfin:8096`.  Clients on your LAN can
use DNS or `/etc/hosts` to resolve `*.svc.internal` to the proxy host.  

> **Temporary compatibility:** legacy LAN clients can still hit the
> server directly on port 8096 because the Jellyfin service exposes that port
> on the host. You do not need a proxy rule. When everything is on
> `*.svc.internal` or using Tailscale you can remove the host mapping if you
> wish.
With this pattern you can add other stacks (Sonarr, Radarr, etc.) by simply
attaching them to the `internal` network and adding proxy rules; no port
mappings are required in their compose files.

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
