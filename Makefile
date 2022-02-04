#---------------
# [ ENV ]
#---------------
-include .env

.DEFAULT_GOAL := help

# получим и установим ip контейнера nginx
NGINX_IP = $(shell docker inspect -f '{{range .NetworkSettings.Networks}} {{.IPAddress}} {{end}}' ${COMPOSE_PROJECT_NAME}-nginx)

##
##╔                 ╗
##║  base commands  ║
##╚                 ╝

help: ##Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

copyinitdata: ## Копирует файлы по директориям из initdata
	cp .env-exeplame .env
	cp -r ./docker/initdata/bash_history/* ./bash_history/
	cp ./docker/initdata/bitrixsetup.php ./www/bitrixsetup.php
	cp ./docker/initdata/restore.php ./www/restore.php
	
setupclear: ## Очищаем мусор после установки битрикса
	@$(MAKE) rmgit
	@$(MAKE) rmbitrix

rmgit: # Удаляет git
	rm -v ./www/.gitkeep
	rm -rfv .git

rmbitrix: # Удаляет мусор из www
	rm -v ./www/bitrixsetup.php
	rm -v ./www/restore.php

sethost: #установим host ip в .hosts контейнера php
	docker exec -it --user root ${COMPOSE_PROJECT_NAME}-php bash -c "echo '${NGINX_IP} ${NGINX_HOST}' >> /etc/hosts"


##
##╔                           ╗
##║  docker-compose commands  ║
##╚                           ╝

dc-ps: ## Список запущенных контейнеров.
	docker-compose ps

dc-up: ## Создаем(если нет) образы и контейнеры, запускаем контейнеры.
	docker-compose up -d
	@$(MAKE) sethost

dc-stop: ## Останавливает контейнеры.
	docker-compose stop

dc-down: ##Останавливает, удаляет контейнеры. docker-compose down --remove-orphans
	docker-compose down --remove-orphans

dc-down-clear: ##Останавливает, удаляет контейнеры и образы. docker-compose down -v --remove-orphans
	docker-compose down -v --remove-orphans

dc-console-db: ##Зайти в консоль mysql
	docker-compose exec ${COMPOSE_PROJECT_NAME}-mysql mysql -u $(MYSQL_USER) --password=$(MYSQL_PASSWORD) $(MYSQL_DATABASE)

dc-console-php: ##php консоль под www-data
	docker exec -it --user www-data ${COMPOSE_PROJECT_NAME}-php bash

dc-console-php-root: ##php консоль под root
	docker exec -it --user root ${COMPOSE_PROJECT_NAME}-php bash

##
##╔                     ╗
##║  database commands  ║
##╚                     ╝

db-dump: ## Сделать дамп БД
	docker exec ${COMPOSE_PROJECT_NAME}-mysql mysqldump -u $(MYSQL_USER) --password=$(MYSQL_PASSWORD) $(MYSQL_DATABASE) --no-tablespaces | gzip > ./docker/dump.sql.gz
	@if [ -f ./docker/dump.sql.gz ]; then \
		mv  ./docker/dump.sql.gz ./docker/dumps/$(shell date +%Y-%m-%d_%H%M%S)_dump.sql.gz; \
	fi

db-restore: ## Восстановить данные в БД. Параметр path - путь до дампа. Пример: make db-restore path=./docker/dumps/2021-11-12_185741_dump.sql.gz
	gunzip < $(path) | docker exec -i ${COMPOSE_PROJECT_NAME}-mysql mysql -u $(MYSQL_USER) --password=$(MYSQL_PASSWORD) $(MYSQL_DATABASE)


