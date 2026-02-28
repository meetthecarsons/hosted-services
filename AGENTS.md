# Agents

This file can be used to record any long‑running "agent" processes or lightweight services that
are not managed via a Docker Compose stack in `stacks/`.

Examples might include:

```
# backup agent running on ds-s-01
backupd
# prometheus node exporter installed on every host
node-exporter
```

Use it the same way as `HOSTS.md`: update manually when you install or remove an agent.
