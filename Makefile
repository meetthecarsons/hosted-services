.PHONY: up down pull logs sops-up

up:
	@echo "usage: make up SERVICE=<name>"
	docker compose -f stacks/$(SERVICE)/docker-compose.yaml up -d


down:
	docker compose -f stacks/$(SERVICE)/docker-compose.yaml down


pull:
	docker compose -f stacks/$(SERVICE)/docker-compose.yaml pull


logs:
	docker compose -f stacks/$(SERVICE)/docker-compose.yaml logs -f


# Convenience: decrypt a tracked .env.sops, run the stack, then remove plaintext.
# Usage: make SERVICE=arrgh-proton sops-up
sops-up:
	@echo "Decrypting stacks/$(SERVICE)/.env.sops -> using secure temp file and running compose"
	@TMP=$$(mktemp -p /tmp sops-up.XXXXXX) && \
		if [ -f age_key.txt ]; then export SOPS_AGE_KEY_FILE=$(PWD)/age_key.txt; fi && \
		SOPS_AGE_KEY_FILE=$${SOPS_AGE_KEY_FILE:-} sops -d stacks/$(SERVICE)/.env.sops > $$TMP && \
		chmod 600 $$TMP && \
		docker compose --env-file $$TMP -f stacks/$(SERVICE)/docker-compose.yaml up -d && \
		if command -v shred >/dev/null 2>&1; then shred -u $$TMP; else rm -f $$TMP; fi

# Encrypt or decrypt a passed-in file.
# Usage:
#   make FILE=stacks/arrgh-proton/.env sops-encrypt
#   make FILE=stacks/arrgh-proton/.env.sops sops-decrypt
.PHONY: sops-encrypt sops-decrypt

sops-encrypt:
	@if [ -z "$(FILE)" ]; then echo "usage: make sops-encrypt FILE=path"; exit 1; fi
	@echo "Encrypting $(FILE) -> $(FILE).sops"
	@sops -e --input-type dotenv $(FILE) > $(FILE).sops

sops-decrypt:
	@if [ -z "$(FILE)" ]; then echo "usage: make sops-decrypt FILE=path.sops"; exit 1; fi
	@echo "Decrypting $(FILE) -> $(FILE:.sops=) using a secure temp file"
	@TMP=$$(mktemp -p /tmp sops-decrypt.XXXXXX) && \
		echo "using tmp: $$TMP" && \
		if [ -f age_key.txt ]; then export SOPS_AGE_KEY_FILE=$(PWD)/age_key.txt; fi && \
		SOPS_AGE_KEY_FILE=$${SOPS_AGE_KEY_FILE:-} sops -d $(FILE) > $$TMP && \
		chmod 600 $$TMP && \
		cat $$TMP > $(FILE:.sops=) && \
		if command -v shred >/dev/null 2>&1; then shred -u $$TMP; else rm -f $$TMP; fi
