# Nextcloud

This stack runs a modular Nextcloud installation with separate containers for each component:

- **Nextcloud 28 (FPM)** - Core application
- **MariaDB 11** - Database backend
- **Redis 7** - Caching and session store
- **Collabora Online** - Real-time document editing (LibreOffice)
- **Nginx** - Web server and reverse proxy
- **Tailscale** - Network access

## Configuration

Create a `.env` file with the following variables:

```
TS_AUTH_KEY=tskey-auth-XXXXXXXXXXXXXX
MYSQL_ROOT_PASSWORD=changeme
MYSQL_USER=nextcloud
MYSQL_PASSWORD=changeme
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=changeme
COLLABORA_HOST=collabora.eland-wyrm.ts.net
SMTP_USER=nextcloud@relay.b0rked.xyz
SMTP_PASSWORD=your-mailgun-password
NEXTCLOUD_MAIL_FROM=noreply@eland-wyrm.ts.net
```

Refer to `.env.example` for all available options.

## Starting the Stack

```bash
cd ~/hosted-services/stacks/nextcloud
docker compose up -d
```

## First-Time Setup

After the containers are running, Nextcloud will initialize the database on first access. The setup wizard will guide you through the remaining configuration.

## Performance Tuning

The stack is configured for NFS compatibility with UID/GID 2000:2000. Adjust memory limits and other resources in the docker-compose.yaml as needed for your environment.
