.PHONY: help up down pull logs

help:
	@echo "Usage: make <target> [VARIABLE=...]"
	@echo ""
	@echo "Common targets:"
	@echo "  help                      Show this help"
	@echo "  up SERVICE=<name>         Start stack (detached)"
	@echo "  down SERVICE=<name>       Stop stack"
	@echo "  pull SERVICE=<name>       Pull images for stack"
	@echo "  logs SERVICE=<name>       Follow stack logs"
	@echo ""
	@echo "SOPS targets:"
	@echo "  sops-up SERVICE=<name>    Decrypt stack .env.sops to a temp and run compose"
	@echo "  sops-reencrypt FILE=...    Re-encrypt a single .sops file using .sops.yaml policy"
	@echo "  sops-reencrypt-all         Re-encrypt all .sops files under stacks/ using .sops.yaml policy"
	@echo "  sops-encrypt FILE=...     Encrypt a plaintext env file -> FILE.sops"
	@echo "  sops-decrypt FILE=...     Decrypt a .sops file to plaintext (writes FILE without .sops)"


up:
	@echo "usage: make up SERVICE=<name>"
	docker compose -f stacks/$(SERVICE)/docker-compose.yaml up -d


down:
	docker compose -f stacks/$(SERVICE)/docker-compose.yaml down


pull:
	docker compose -f stacks/$(SERVICE)/docker-compose.yaml pull


logs:
	docker compose -f stacks/$(SERVICE)/docker-compose.yaml logs -f


# Encrypt or decrypt a passed-in file.
# Usage:
#   make FILE=stacks/arrgh-proton/.env sops-encrypt
#   make FILE=stacks/arrgh-proton/.env.sops sops-decrypt
.PHONY: sops-up sops-reencrypt sops-reencrypt-all sops-encrypt sops-decrypt

# Convenience: decrypt a tracked .env.sops, run the stack, then remove plaintext.
# Usage: make SERVICE=arrgh-proton sops-up
sops-up:
	@echo "Decrypting stacks/$(SERVICE)/.env.sops -> using secure temp file and running compose"
	@make sops-decrypt FILE=stacks/$(SERVICE)/.env.sops && \
		docker compose -f stacks/$(SERVICE)/docker-compose.yaml up -d


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
