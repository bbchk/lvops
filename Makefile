.DEFAULT_GOAL := help
.PHONY: .env create-network setup build install up down clean install-deps

.ONESHELL:
.SHELLFLAGS := -eu -c
SHELL := bash

export COMPOSE_PATH_SEPARATOR = :
export COMPOSE_FILE ?= $(compose_file):$(compose_file_custom)
export COMPOSE_PROJECT_NAME ?= $(compose_project_name)
export APP_GROUP_ID ?= $(shell echo $${SUDO_GID:-$$(id -g)})
export APP_USER_ID ?= $(shell echo $${SUDO_UID:-$$(id -u)})

help:
	@cat <<EOF
	|===============================
	| Available targets:
	| ------------------------------
	|  Primary:
	|
	|   - setup        Boot up project for local development.
	|   - build        Build project images.
	|   - up           Start project containers.
	|   - down         Stop and remove project containers.
	|   - clean        Shut down compose project and remove all generated artifacts.
	|
	|   - test (WIP)   Boot up project and run tests inside main application container.
	|
	| ------------------------------
	|  Auxiliary:
	|
	|   - .env                      Write .env files from .env.example ones OR prompt the user to overwrite them.
	|   - create-network    	Creates external network.
	|   - install-deps 			Run main container and install dependencies from lock file.
	|   - $(compose_file_custom)   Creates custom docker compose file.
	|
	| ------------------------------
	|  Quality of life:
	|
	|   - help   Print this help message.
	|   - stop   Stop project containers.
	|   - logs   Follow logs of service(s). Use `make logs` or `make logs s1 s2 s3`.
	|   - exec   Exec sh into service container. Use `make exec s1`.
	|
	|===============================
	EOF

# == Primary targets below ======================

setup: create-network build install-deps up

build: .env
	docker compose build

install-deps:
	docker compose run --no-deps --rm app -- pnpm install --frozen-lockfile

up:
	 docker compose up -d --remove-orphans --wait --wait-timeout 30

stop:
	docker compose stop

down:
	docker compose down --remove-orphans

clean: down
	rm -rf .env "$(compose_file_custom)"

# == Auxiliary targets below ======================

update-submodules:
	git submodule update --init --recursive

$(compose_file_custom):
	touch "$(compose_file_custom)"

.env: $(compose_file_custom)
	-@cp -i ./src/.env.example ./src/.env

	temp_file=$$(mktemp)

	cat <<EOF > $$temp_file
		# ---------------------------------------------------
		# All the environment variables below are build-related.
		# Application-specific ones are placed under src/ folder
		# ---------------------------------------------------

		APP_PORT="$(app_port)"
		APP_IMAGE="$(app_image)"
		APP_TARGET="$(app_target)"

		# ---------------------------------------------------
		# Env vars below are for sake of explicity.
		# These values are derived from defaults in Makefile and shouldn't be adjusted here.
		# ---------------------------------------------------

		COMPOSE_FILE="$(compose_file):$(compose_file_custom)"
		COMPOSE_PROJECT_NAME="$(compose_project_name)"
		APP_GROUP_ID="$(APP_GROUP_ID)"
		APP_USER_ID="$(APP_USER_ID)"
		EOF

		cp -i $$temp_file .env
		rm -f $$temp_file

create-network:
	-@docker network create lv >/dev/null 2>&1 || true

# == QoL targets below ======================

logs:
	docker compose logs -f $(filter-out $@,$(MAKECMDGOALS))

exec:
	service="$(firstword $(filter-out $@,$(MAKECMDGOALS)))"
	docker compose exec $${service:-app} bash
