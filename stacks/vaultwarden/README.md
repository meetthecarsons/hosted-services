# Vaultwarden

This stack runs a lightweight Bitwarden-compatible password manager server with a Tailscale sidecar for secure, encrypted access from the tailnet.

## Overview

Vaultwarden is an unofficial Bitwarden server implementation written in Rust. The stack includes:
- **vaultwarden** - The main password manager service
- **tailscale** - Sidecar for secure tailnet access with automatic HTTPS certificates

This setup allows you to access Vaultwarden as `https://vault.<your-tailnet>.ts.net` directly from any device on your Tailscale network without exposing ports to the Internet.

## Quick Start

1. Create a `.env` file with your configuration:

```sh
# Required: Get an auth key from https://login.tailscale.com/admin/settings/keys
TS_AUTH_KEY=tskey-xxxxxxxxxxxxxxxxxxxx

# Optional: Customize these
TS_HOSTNAME=vaultwarden
TAILSCALE_DOMAIN=your-tailnet.ts.net
TAILSCALE_STATE=./tailscale_state
VAULTWARDEN_DATA=./data

# Vaultwarden settings
SIGNUPS_ALLOWED=false
INVITATIONS_ALLOWED=true
```

2. Start the stack:

```sh
make up SERVICE=vaultwarden
```

3. On first run, the Tailscale sidecar will authenticate using the auth key. Check that both services are running:

```sh
docker compose -f stacks/vaultwarden/docker-compose.yaml ps
```

4. Access from any device on your Tailscale network at:
   - `https://vault.<your-tailnet>.ts.net`
   - Or use the default hostname: `https://vaultwarden.<your-tailnet>.ts.net`

The TLS certificate is automatically managed by Tailscale.

## Storage

SQLite database is stored in the `data/` directory. For production, consider:

- Ensuring `VAULTWARDEN_DATA` is mounted to persistent storage on the host
- Migrating to PostgreSQL by setting `DATABASE_URL`

## Environment Variables

Required:
- `TS_AUTH_KEY` - Tailscale auth key from https://login.tailscale.com/admin/settings/keys

Optional:
- `TS_HOSTNAME` - Name the device gets in your tailnet (default: `vaultwarden`)
- `TAILSCALE_DOMAIN` - Your Tailscale domain for the `DOMAIN` variable (default: `example.ts.net`)
- `TAILSCALE_STATE` - Where to persist Tailscale state (default: `./tailscale_state`)
- `VAULTWARDEN_DATA` - Where to persist Vaultwarden data (default: `./data`)
- `SIGNUPS_ALLOWED` - Allow new accounts (default: `false`)
- `INVITATIONS_ALLOWED` - Allow existing users to invite others (default: `true`)
- `SHOW_PASSWORD_HINT` - Show password hints on login (default: `false`)

## Tailscale Setup

The Tailscale sidecar handles all networking and TLS automatically:

1. **Get an auth key**: Visit https://login.tailscale.com/admin/settings/keys and create a new auth key
2. **Set `TS_AUTH_KEY` in `.env`**
3. **Start the stack** - Tailscale will authenticate automatically
4. **Verify connectivity**: Ping the device from another computer on your tailnet

```sh
ping vaultwarden.<your-tailnet>.ts.net
```

Clients on the Bitwarden app/web can connect using:
- Server URL: `https://vault.<your-tailnet>.ts.net` (or whatever custom domain you set)

## Logs

View logs with:

```sh
make logs SERVICE=vaultwarden
```

Check Tailscale sidecar logs specifically:

```sh
docker logs vaultwarden-tailscale -f
```

## Troubleshooting

- **Tailscale not connecting**: Verify the auth key is valid and hasn't been used elsewhere
- **Can't reach from tailnet**: Wait a moment for DNS to propagate; check the device shows up at https://login.tailscale.com/admin/machines
- **TLS certificate errors**: Tailscale provides certificates automatically; any errors should clear after a few seconds

## References

- [Vaultwarden GitHub](https://github.com/dani-garcia/vaultwarden)
- [Vaultwarden Wiki](https://github.com/dani-garcia/vaultwarden/wiki)
- [Tailscale Docker Documentation](https://hub.docker.com/r/tailscale/tailscale)
