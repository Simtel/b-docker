#---------------
# [ ENV ]
#---------------
-include .env

.DEFAULT_GOAL := help

##
##╔                 ╗
##║  base commands  ║
##╚                 ╝

help: ##Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

copyinitdata: ## Копирует файлы по директориям из initdata
	cp .env-exeplame .env
	cp -r ./initdata/bash_history/* ./bash_history/
	cp ./initdata/bitrixsetup.php ./www/bitrixsetup.php
	cp ./initdata/restore.php ./www/restore.php
	
setupclear: ## Очищаем мусор после установки битрикса
	@$(MAKE) rmgit
	@$(MAKE) rmbitrix

rmgit: # Удаляет git
	rm -v ./www/.gitkeep
	rm -rfv .git

rmbitrix: # Удаляет мусор из www
	rm -v ./www/bitrixsetup.php
	rm -v ./www/restore.php 

##
##╔                           ╗
##║  docker-compose commands  ║
##╚                           ╝

dc-ps: ## Список запущенных контейнеров.
	docker-compose ps

dc-up: ## Создаем(если нет) образы и контейнеры, запускаем контейнеры.
	docker-compose up -d

dc-stop: ## Останавливает контейнеры.
	docker-compose stop

dс-down: ##Останавливает, удаляет контейнеры. docker-compose down --remove-orphans
	docker-compose down --remove-orphans

dс-down-clear: ##Останавливает, удаляет контейнеры и образы. docker-compose down -v --remove-orphans
	docker-compose down -v --remove-orphans

dc-console-db: ##Зайти в консоль mysql
	docker-compose exec mysql mysql -u $(MYSQL_USER) --password=$(MYSQL_PASSWORD) $(MYSQL_DATABASE)

dc-console-php: ##php консоль под www-data
	docker exec -it --user www-data php bash

dc-console-php-root: ##php консоль под root
	docker exec -it --user root php bash

##
##╔                     ╗
##║  database commands  ║
##╚                     ╝

db-dump: ## Сделать дамп БД
	docker exec mysql mysqldump -u $(MYSQL_USER) --password=$(MYSQL_PASSWORD) $(MYSQL_DATABASE) --no-tablespaces | gzip > ./dump.sql.gz
	@if [ -f ./dump.sql.gz ]; then \
		mv  ./dump.sql.gz ./dumps/$(shell date +%Y-%m-%d_%H%M%S)_dump.sql.gz; \
	fi

db-restore: ## Восстановить данные в БД. Параметр path - путь до дампа. Пример: make db-restore path=./dumps/2021-11-12_185741_dump.sql.gz
	gunzip < $(path) | docker exec -i mysql mysql -u $(MYSQL_USER) --password=$(MYSQL_PASSWORD) $(MYSQL_DATABASE)


