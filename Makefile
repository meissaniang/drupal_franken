include .env

default: up

COMPOSER_ROOT ?= /opt/drupal
DRUPAL_ROOT ?= /opt/drupal/web

## generate ssl for local environnement
.PHONY: generate-localhost-certs
generate-localhost-certs:
	sh generate-localhost-certs.sh

## local-up: start container for dev environnement
.PHONY: local-up
local-up:
	@echo "Starting up containers for $(PROJECT_NAME)..."
	@$(MAKE) -f Makefile generate-localhost-certs
	docker build -t $(PROJECT_NAME)_frankenphp .
	docker-compose -f docker-compose.yml up -d --remove-orphans

## down	:	Stop containers.
.PHONY: down
down: stop -f docker-compose-prod.yml

## down	:	Stop containers for dev environnement.
.PHONY: local-down
local-down: stop -f docker-compose.yml

## start	:	Start containers without updating for dev environnement.
.PHONY: local-start
local-start:
	@echo "Starting containers for $(PROJECT_NAME) from where you left off..."
	@docker-compose -f docker-compose.yml start

## stop	:	Stop prod containers.
.PHONY: local-stop
local-stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose -f docker-compose.yml stop

## prune	:	Remove containers and their volumes.
##		You can optionally pass an argument with the service name to prune single container
##		prune mariadb	: Prune `mariadb` container and remove its volumes.
##		prune mariadb solr	: Prune `mariadb` and `solr` containers and remove their volumes.

## Remove containers and their volumes for dev environnement.
.PHONY: local-prune
local-prune:
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose -f docker-compose.yml down -v $(filter-out $@,$(MAKECMDGOALS))

## ps	:	List running containers.
.PHONY: ps
ps:
	@docker ps --filter name='$(PROJECT_NAME)*'

## drush	:	Executes `drush` command in a specified `DRUPAL_ROOT` directory (default is `/var/www/html/web`).
##		To use "--flag" arguments include them in quotation marks.
##		For example: make drush "watchdog:show --type=cron"
.PHONY: drush
drush:
	docker exec $(shell docker ps --filter name='^/$(PROJECT_NAME)_frankenphp' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) $(filter-out $@,$(MAKECMDGOALS))

## import local database
.PHONY: restore-db
restore-db:
	docker exec $(shell docker ps --filter name='^/$(PROJECT_NAME)_postgres' --format "{{ .ID }}") psql -U $(DB_USER) -d $(DB_NAME) -f /docker-entrypoint-initdb.d/export.sql

## export local database
.PHONY: exports-db
exports-db:
	docker exec $(shell docker ps --filter name='^/$(PROJECT_NAME)_postgres' --format "{{ .ID }}") pg_dump -U $(DB_USER) -d $(DB_NAME) -f /docker-entrypoint-initdb.d/export.sql

## logs	:	View containers logs.
##		You can optinally pass an argument with the service name to limit logs
##		logs php	: View `php` container logs.
##		logs nginx php	: View `nginx` and `php` containers logs.
.PHONY: logs
logs:
	@docker-compose logs -f $(filter-out $@,$(MAKECMDGOALS))

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
