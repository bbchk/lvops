.DEFAULT_GOAL := help
.PHONY: .env create-network setup build install down clean install-deps logs exec help

.ONESHELL:
.SHELLFLAGS := -eu -c
SHELL := bash

MAKEFLAGS += --no-print-directory
.SILENT: help-primary help-auxiliary help-qol help create-network
.IGNORE: create-network

export COMPOSE_PATH_SEPARATOR = :
export COMPOSE_FILE ?= $(compose_file):$(compose_file_custom)
export COMPOSE_PROJECT_NAME ?= $(compose_project_name)
export APP_GROUP_ID ?= $(shell echo $${SUDO_GID:-$$(id -g)})
export APP_USER_ID ?= $(shell echo $${SUDO_UID:-$$(id -u)})

compose_file = ops/compose.yaml
compose_file_custom = ops/compose.custom.yaml

help-primary:
	cat <<EOF
	|------------------------------
	| Available targets:
	|------------------------------
	|  Primary:
	|
	|   - setup        Boot up project for local development.
	|   - build        Build project images.
	|   - up           Start project containers.
	|   - down         Stop and remove project containers.
	|   - clean        Shut down compose project and remove all generated artifacts.
	|   - test (WIP)   Boot up project and run tests inside main application container.
	EOF

help-auxiliary:
	cat <<EOF
	| ------------------------------
	|  Auxiliary:
	|
	|   - .env                      Write .env files from .env.example ones OR prompt the user to overwrite them.
	|   - create-network    	Creates external network.
	|   - install-deps 			Run main container and install dependencies from lock file.
	|   - $(compose_file_custom)   Creates custom docker compose file.
	EOF

help-qol:
	cat <<EOF
	| ------------------------------
	|  Quality of life:
	|
	|   - help   Print this help message.
	|   - stop   Stop project containers.
	|   - logs   Follow logs of service(s). Use 'make logs' or 'make logs s1 s2 s3'.
	|   - exec   Exec sh into service container. Use 'make exec s1'.
	EOF

# == Primary targets below ======================

setup: create-network build install-deps up

build: .env
	docker compose build

up:
	 docker compose up -d --remove-orphans --wait --wait-timeout 30

stop:
	docker compose stop

down:
	docker compose down --remove-orphans

$(compose_file_custom):
	touch "$(compose_file_custom)"

# == Auxiliary targets below ======================

create-network:
	docker network create lv >/dev/null 2>&1 || true

# == QoL targets below ======================

logs:
	docker compose logs -f $(filter-out $@,$(MAKECMDGOALS))

exec:
	service="$(firstword $(filter-out $@,$(MAKECMDGOALS)))"
	docker compose exec $${service:-app} bash
