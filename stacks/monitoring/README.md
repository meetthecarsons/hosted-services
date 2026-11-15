# monitoring

Prometheus + Grafana + Alertmanager + ntfy-alertmanager bridge + cAdvisor,
with tardis's node_exporter alongside. Grafana, Prometheus, Alertmanager,
the bridge, and cAdvisor all share the tailscale sidecar's network namespace
(tailnet node `graf`) and talk over localhost:

| Service | Port (in shared netns) |
|---|---|
| grafana | 3000 |
| prometheus | 9090 |
| alertmanager | 9093 |
| ntfy-alertmanager | 8080 |
| cadvisor | 8085 |

## Alerting path

Prometheus rules (`config/prometheus/rules/`) → Alertmanager → webhook →
ntfy-alertmanager → ntfy.sh **alerts topic**. Everything Alertmanager sends
is loud by definition; the info topic is producer-side only (boot messages,
backup heartbeats) and is never written from here. Resolved notifications
are on.

## Secret handling (non-obvious)

ntfy-alertmanager only takes a config **file**, and topic names are secrets.
`config/ntfy-alertmanager/config.tpl` is committed with a
`__NTFY_ALERTS_TOPIC__` placeholder; the one-shot `ntfy-bridge-config`
service renders the real config into a named volume at `up`, reading
`NTFY_ALERTS_TOPIC` from the env (`.env` ← `.env.sops`). After changing the
topic, `docker compose up -d` re-renders it.

## Dashboards

Grafana dashboards are provisioned from `config/grafana/dashboards/` (file
provider, read-only in the UI; edit the JSON and redeploy). `containers.json`
is the "what's running" view built on cadvisor: running containers, stacks,
24h restarts, and a per-container table of uptime, CPU and memory. It picks
the Prometheus data source with a dashboard variable, so no data source UID is
baked in.

## First deploy

1. Add `NTFY_ALERTS_TOPIC` to `.env.sops` (`make sops-decrypt` / edit /
   `make sops-encrypt` — value from Vaultwarden "ntfy topics").
2. Create the Alertmanager data dir on the host:
   `install -d -o 2000 -g 2000 /mnt/fast-pool-01/appdata/alertmanager/data`
3. `make deploy SERVICE=monitoring`
4. Verify: all six containers up; `amtool` or the Alertmanager UI shows the
   ntfy receiver; fire a test alert and expect it on the alerts topic;
   check bridge logs for config-parse errors (the scfg template was written
   against upstream docs — validate on first run).
