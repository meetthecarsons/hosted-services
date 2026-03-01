# Hosted Services Repository

This repository contains Docker Compose stacks for services that run on various hosts in my home network. It is intentionally minimal and CLI‑centric.

## Structure

```
stacks/
  arrgh-proton/          # VPN and media tooling suite
  jellyfin/              # media server with Caddy reverse proxy
  immich/                # photo management
  mealie/                # recipe manager
  minecraft-bedrock/     # game server
  nextcloud/             # all-in-one Nextcloud container
  opennotebook/          # note-taking application
  windmill/              # Windmill server and workers
```

Each subdirectory contains a `docker-compose.yml` and usually a `README.md` with service‑specific notes.

## Usage

1. Clone this repository on the host machine where you want to run a stack:
   ```bash
   git clone <repo-url> ~/hosted-services
   cd ~/hosted-services
   ```

2. Inspect or create an `.env` file in the desired stack directory (use the `.env.example` if present).

3. Start the stack:
   ```bash
   cd stacks/<stackname>
   docker compose up -d
   # or use the makefile: make SERVICE=<stackname> up
   ```

4. To stop or update, use the corresponding `docker compose` commands or `make` targets.

## Host assignments

See `HOSTS.md` for a handwritten mapping of which services live on which servers. This file is purely informational and not used by any automation.

## Helper commands

A simple `Makefile` is provided at the repo root to reduce typing (see it for available targets).

## Adding a new service

1. Add a new directory under `stacks/`.
2. Put your `docker-compose.yml` inside and any helpful docs.
3. Optionally add a `.env.example` and update `.gitignore` if you need to ignore local state.
4. Commit and push.

## Philosophy

- **Keep it simple.** Every service is self-contained; no orchestration layer, GUI, or Portainer metadata.
- **Manage per‑host.** Each physical machine clones the repo and runs only the services it needs.
- **Document, don’t encode.** The repository doesn’t know where services belong; `HOSTS.md` helps you remember.

## SOPS operator workflow

 - **Prepare secrets:** create an untracked plaintext file `stacks/<stack>/ .env` with secret values (use `stacks/<stack>/.env.example` as a template).
 - **Encrypt for repo:** run `sops -e stacks/<stack>/.env > stacks/<stack>/.env.sops` and commit the resulting `.env.sops` file.
 - **Run the stack:** locally decrypt when needed with `sops -d stacks/<stack>/.env.sops > stacks/<stack>/.env` then `docker compose -f stacks/<stack>/docker-compose.yaml up -d`.
 - **Cleanup:** remove the plaintext `stacks/<stack>/.env` after the stack is running.

This repository tracks encrypted secret artifacts (`.env.sops`) and treats plaintext `.env` files as local operator-only files. See `.sops.yaml` for the repository encryption policy.

**Developer Dependencies**

- **Required tools:** `pre-commit`, `sops`, `age`/`age-keygen`.
- **Recommended helpers** (used by hooks in `.pre-commit-config.yaml`): `shfmt`, `shellcheck`, `hadolint`, `yamllint`, and `detect-secrets`.

Install examples:

- Nix (user profile):

   ```bash
   nix profile install nixpkgs#pre-commit nixpkgs#sops nixpkgs#age nixpkgs#shfmt nixpkgs#shellcheck nixpkgs#yamllint nixpkgs#hadolint
   python -m pip install --user detect-secrets
   ```

- Debian / Ubuntu (apt + releases):

   ```bash
   sudo apt update
   sudo apt install -y python3-pip shellcheck yamllint
   pip3 install --user pre-commit detect-secrets
   # shfmt and hadolint releases (if not in apt or you want latest):
   curl -sL -o /usr/local/bin/shfmt https://github.com/mvdan/sh/releases/latest/download/shfmt_v3.6.0_linux_amd64
   chmod +x /usr/local/bin/shfmt
   curl -sL -o /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
   chmod +x /usr/local/bin/hadolint
   # sops + age (install from package or releases)
   pip3 install --user sops
   ```

- macOS (Homebrew / pipx):

   ```bash
   brew install pre-commit shfmt shellcheck yamllint hadolint sops age
   pipx install detect-secrets || pip3 install --user detect-secrets
   ```

Enable hooks and run once:

```bash
pre-commit install
pre-commit run --all-files
```

If `detect-secrets` flags existing secrets, create a baseline so approved secrets are not repeatedly reported:

```bash
detect-secrets scan > .secrets.baseline
git add .secrets.baseline
```

Keep `age_key.txt` private (it is gitignored); CI should use secret storage to provide keys if automated decrypt is required.

**Pre-Commit Dependencies**

 - **pre-commit**: install via `pipx install pre-commit` (or `pip install --user pre-commit`). Install hooks in the repo with `pre-commit install`.
 - **Optional / recommended tools:**
    - **shfmt**: shell formatter. Debian: `sudo curl -sSL -o /usr/local/bin/shfmt https://github.com/mvdan/sh/releases/download/v3.6.0/shfmt_v3.6.0_linux_amd64 && sudo chmod +x /usr/local/bin/shfmt`; macOS: `brew install shfmt`.
    - **shellcheck**: shell linter. Debian: `sudo apt install shellcheck`; macOS: `brew install shellcheck`.
    - **yamllint**: YAML linter. Debian: `sudo apt install yamllint`; macOS: `brew install yamllint`.
    - **hadolint**: Dockerfile linter. Install from releases or `brew install hadolint` on macOS.
    - **detect-secrets**: secret detector. Install with `pipx install detect-secrets` or `pip install --user detect-secrets`.

Run the hooks locally once with:
```
pre-commit run --all-files
```

If `detect-secrets` flags existing approved keys, create a baseline:
```
detect-secrets scan > .secrets.baseline
git add .secrets.baseline
```
