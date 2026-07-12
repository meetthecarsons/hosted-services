.PHONY: help up down pull logs deploy deploy-diff

SHELL := /bin/bash

help:
	@echo "Usage: make <target> [VARIABLE=...]"
	@echo ""
	@echo "Common targets:"
	@echo "  help                      Show this help"
	@echo "  deploy SERVICE=<name>     Sync stack to $(DEPLOY_ROOT)/<name>, decrypt env, compose up -d"
	@echo "  deploy-diff SERVICE=<name> Preview what deploy would change (no writes)"
	@echo "  up SERVICE=<name>         Start deployed stack (no sync; use deploy for changes)"
	@echo "  down SERVICE=<name>       Stop deployed stack"
	@echo "  pull SERVICE=<name>       Pull images for deployed stack"
	@echo "  logs SERVICE=<name>       Follow deployed stack logs"
	@echo ""
	@echo "SOPS targets:"
	@echo "  sops-reencrypt FILE=...    Re-encrypt a single .sops file using .sops.yaml policy"
	@echo "  sops-reencrypt-all         Re-encrypt all .sops files under stacks/ using .sops.yaml policy"
	@echo "  sops-encrypt FILE=...     Encrypt a plaintext env file -> FILE.sops"
	@echo "  sops-decrypt FILE=...     Decrypt a .sops file to plaintext (writes FILE without .sops)"


# ---------------------------------------------------------------------------
# Deploy workflow: the repo is the source of truth, running stacks live in
# deployed copies under $(DEPLOY_ROOT). A `git pull` can never mutate a
# running service; changes only land via an explicit `make deploy`.
#
#   make deploy SERVICE=jellyfin            sync + env + docker compose up -d
#   make deploy SERVICE=jellyfin DELETE=1   also delete files removed from repo
#                                           (deployed .env is always protected)
#   make deploy-diff SERVICE=jellyfin       dry-run preview of the sync
#
# Env handling, in order of preference:
#   1. stacks/<name>/.env.sops exists  -> decrypted to deployed .env (chmod 600)
#   2. stacks/<name>/.env exists       -> copied as-is by the rsync
#   3. neither                         -> stack runs without an env file
# ---------------------------------------------------------------------------
DEPLOY_ROOT ?= /opt/stacks

deploy:
	@if [ -z "$(SERVICE)" ]; then echo "usage: make deploy SERVICE=<name> [DELETE=1]"; exit 1; fi
	@if [ ! -d "stacks/$(SERVICE)" ]; then echo "no such stack: stacks/$(SERVICE)"; exit 1; fi
	@mkdir -p "$(DEPLOY_ROOT)/$(SERVICE)"
	rsync -a $(if $(DELETE),--delete --filter='P /.env') stacks/$(SERVICE)/ "$(DEPLOY_ROOT)/$(SERVICE)/"
	@if [ -f "stacks/$(SERVICE)/.env.sops" ]; then \
		echo "Decrypting .env.sops -> $(DEPLOY_ROOT)/$(SERVICE)/.env"; \
		sops -d --input-type dotenv --output-type dotenv "stacks/$(SERVICE)/.env.sops" > "$(DEPLOY_ROOT)/$(SERVICE)/.env" || exit 1; \
		chmod 600 "$(DEPLOY_ROOT)/$(SERVICE)/.env"; \
	fi
	@if [ -f "$(DEPLOY_ROOT)/$(SERVICE)/docker-compose.yml" ] && ls stacks/$(SERVICE)/compose.y*ml >/dev/null 2>&1; then \
		echo "WARNING: stale docker-compose.yml in $(DEPLOY_ROOT)/$(SERVICE) alongside repo compose.yaml — consider removing it"; \
	fi
	cd "$(DEPLOY_ROOT)/$(SERVICE)" && docker compose up -d --remove-orphans
	@echo "Deployed $(SERVICE) -> $(DEPLOY_ROOT)/$(SERVICE)"

deploy-diff:
	@if [ -z "$(SERVICE)" ]; then echo "usage: make deploy-diff SERVICE=<name>"; exit 1; fi
	@if [ ! -d "stacks/$(SERVICE)" ]; then echo "no such stack: stacks/$(SERVICE)"; exit 1; fi
	rsync -avn --delete --filter='P /.env' stacks/$(SERVICE)/ "$(DEPLOY_ROOT)/$(SERVICE)/"
	@echo "(dry run — nothing was changed; deletions only apply with DELETE=1)"

# Day-2 operations against the *deployed* copy. None of these sync the repo;
# use `make deploy` to push changes out.
up:   COMPOSE_CMD = up -d
down: COMPOSE_CMD = down
pull: COMPOSE_CMD = pull
logs: COMPOSE_CMD = logs -f
up down pull logs:
	@if [ -z "$(SERVICE)" ]; then echo "usage: make $@ SERVICE=<name>"; exit 1; fi
	@if [ ! -d "$(DEPLOY_ROOT)/$(SERVICE)" ]; then echo "not deployed: $(DEPLOY_ROOT)/$(SERVICE) (run make deploy SERVICE=$(SERVICE))"; exit 1; fi
	cd "$(DEPLOY_ROOT)/$(SERVICE)" && docker compose $(COMPOSE_CMD)

# Encrypt or decrypt a passed-in file.
# Usage:
#   make FILE=stacks/arrgh-proton/.env sops-encrypt
#   make FILE=stacks/arrgh-proton/.env.sops sops-decrypt
.PHONY: sops-reencrypt sops-reencrypt-all sops-encrypt sops-decrypt

sops-reencrypt:
	@if [ -z "$(FILE)" ]; then echo "usage: make sops-reencrypt FILE=path/.env.sops"; exit 1; fi
	@make sops-decrypt FILE="$(FILE)" && \
		make sops-encrypt FILE="$(FILE:.sops=)" && \
		rm -f "$(FILE:.sops=)"


sops-reencrypt-all:
	@echo "Re-encrypting all .sops files under stacks/ (delegating to sops-reencrypt)"
	@find stacks -type f -name '*.sops' -print0 | while IFS= read -r -d '' f; do \
		echo "Processing $$f"; \
		$(MAKE) sops-reencrypt FILE="$$f"; \
		done


sops-encrypt:
	@if [ -z "$${SOPS_AGE_KEY_FILE:-}" ]; then echo "SOPS_AGE_KEY_FILE not set. Export the path to your age key file and retry."; exit 1; fi
	@if [ -z "$(FILE)" ]; then echo "usage: make sops-encrypt FILE=path"; exit 1; fi
	@echo "Encrypting $(FILE) -> $(FILE).sops"
	@sops -e --input-type dotenv $(FILE) >$(FILE).sops


sops-decrypt:
	@if [ -z "$${SOPS_AGE_KEY_FILE:-}" ]; then echo "SOPS_AGE_KEY_FILE not set. Export the path to your age key file and retry."; exit 1; fi
	@if [ -z "$(FILE)" ]; then echo "usage: make sops-decrypt FILE=path.sops"; exit 1; fi
	@echo "Decrypting $(FILE) -> $(FILE:.sops=) using a secure temp file"
	@TMP=$$(mktemp -p /tmp sops-decrypt.XXXXXX) && \
		echo "using tmp: $$TMP" && \
		if [ -f age_key.txt ]; then export SOPS_AGE_KEY_FILE=$(PWD)/age_key.txt; fi && \
		SOPS_AGE_KEY_FILE=$${SOPS_AGE_KEY_FILE:-} sops -d --input-type dotenv --output-type dotenv $(FILE) > $$TMP && \
		chmod 600 $$TMP && \
		cat $$TMP > $(FILE:.sops=) && \
		if command -v shred >/dev/null 2>&1; then shred -u $$TMP; else rm -f $$TMP; fi
