# CLAUDE.md

Guidance for AI coding agents working in this repository.

## What this repo is

A CLI-centric collection of Docker Compose stacks for self-hosted services
running across several physical/VPS hosts on a home network. There is no
orchestration layer, GUI, or Portainer — each host runs only the stacks it
needs, and the repo itself is just the source of truth for their config.

## Layout

- `stacks/<name>/` — one self-contained Compose stack per service
  (`compose.yaml`, `.env.example`, optional `README.md`, service-specific
  config). See `stacks/<name>/README.md` for service-specific quirks.
- `steward/<hostname>/` — per-host deployment of
  [stack-agent](https://github.com/rcarson/stack-agent), a daemon that polls
  this repo and reconciles that host's stacks automatically. See
  `steward/README.md`.
- `HOSTS.md` — handwritten, current mapping of which stack runs on which
  host. Purely informational; not read by any automation. Update it whenever
  a stack is added, removed, or moved.
- `Makefile` — `make deploy`/`up`/`down`/`pull`/`logs`, plus the `sops-*`
  targets (see below).

## Deploy model — read before changing Compose files

Running stacks live in deployed copies (typically under `/opt/stacks/<name>`
on `tardis`, or wherever `steward/<hostname>/config.yml` points), **not** in
the repo checkout itself. `git pull` never mutates a running service.

Two ways changes reach a host:
1. **Manual**: `make deploy SERVICE=<name>` — rsyncs the stack directory to
   the deploy root, decrypts `.env.sops` -> `.env` (chmod 600) if present,
   then `docker compose up -d --remove-orphans`. Use `make deploy-diff
   SERVICE=<name>` first to preview the rsync with no writes.
2. **Automatic**: `steward/<hostname>` runs stack-agent, which polls this
   repo's HEAD and reconciles the stacks listed in its `config.yml`.

Check `HOSTS.md` to know which mode applies to a given host before assuming
a Compose edit takes effect immediately.

## Secrets (SOPS + age)

- Tracked: encrypted `stacks/<name>/.env.sops`. Never tracked: plaintext
  `stacks/<name>/.env` (gitignored) or `age_key.txt`.
- Policy lives in `.sops.yaml` (recipients + which keys get encrypted).
  `make sops-encrypt`/`sops-decrypt`/`sops-reencrypt(-all)` all require
  `SOPS_AGE_KEY_FILE` exported — there is no fallback key path.
- Never print, log, or write decrypted secret values outside of the
  gitignored `.env` files the Makefile targets produce.

## Adding or changing a stack

1. New stack: create `stacks/<name>/`, add `compose.yaml` (not
   `docker-compose.yml` — the Makefile warns on stale legacy filenames
   coexisting with a repo `compose.yaml`), `.env.example` for any secrets,
   and a short `README.md` if there's anything non-obvious about the setup.
2. If it needs secrets, encrypt with `make sops-encrypt FILE=stacks/<name>/.env`
   and commit the resulting `.env.sops`.
3. Update `HOSTS.md` with where it's deployed (or that it isn't yet).
4. Run `pre-commit run --all-files` before committing (shfmt, shellcheck,
   yamllint, hadolint, detect-secrets, plus standard whitespace/EOF/YAML
   checks — see `.pre-commit-config.yaml`).

## Philosophy (keep changes consistent with this)

- Keep it simple: every stack is self-contained, no shared orchestration.
- Manage per-host: don't add logic that assumes every host runs every stack.
- Document, don't encode: `HOSTS.md` is prose, not machine-read config —
  don't wire automation to depend on its contents.
