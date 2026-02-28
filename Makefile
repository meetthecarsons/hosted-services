.PHONY: up down pull logs

up:
	@echo "usage: make up SERVICE=<name>"
	docker compose -f stacks/$(SERVICE)/docker-compose.yml up -d


down:
	docker compose -f stacks/$(SERVICE)/docker-compose.yml down


pull:
	docker compose -f stacks/$(SERVICE)/docker-compose.yml pull


logs:
	docker compose -f stacks/$(SERVICE)/docker-compose.yml logs -f
