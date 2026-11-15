# cadvisor

Exports per-container CPU, memory and lifecycle metrics on `:8085` for
Prometheus. Used on hosts without the `monitoring` stack (crafty); no secrets,
so there is no `.env`. The Prometheus target and its `host` label live in
`monitoring/config/prometheus/prometheus.yml`.
