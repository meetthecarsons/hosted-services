# Host assignments

This file lists which Docker Compose stacks currently run on each host. It is
for reference only; there is no automation tied to this document.

Stacks on tardis run from deployed copies under `/opt/stacks/<stack>` (see
`make deploy` in the Makefile) — never directly from this repo checkout.

```
tardis (ds-s-01, 192.168.60.80 / tailnet "tardis")
  - arrgh-proton      # gluetun VPN + qbittorrent + *arr download suite
  - glance            # dashboard (tailnet "glance")
  - immich            # photos (tailnet "photos")
  - jellyfin          # media server
  - monitoring        # prometheus + grafana + node_exporter (tailnet "graf")
  - vaultwarden       # password manager (tailnet "vault")

crafty (192.168.60.81 / tailnet "crafty")
  - minecraft-bedrock # unverified — confirm and update
```

Not deployed anywhere right now (repo definitions only):

```
  - mealie            # stale deployed copy in /opt/stacks/mealie, not running
  - nextcloud
  - internal / random / reverse-proxy
```

Decommissioned: delamain (its stacks moved to tardis or were retired).
Retired on tardis: homeassistant (migrated to another host ~2026-06-17;
leftover /opt/stacks/homeassistant + appdata pending deletion), tsdproxy
(removed 2026-07-03).

Update this file whenever you add, remove, or relocate a stack.
