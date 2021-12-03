# Docker под 1С-Битрикс
Сборка представляет собой связку:
nginx + php-fpm + mysql + memcached

Здесь и дальше `localhost` может быть изменен на любой домен, который указывается в `.env`

Есть **phpmyadmin** для просмотра БД. http://localhost:8181/
Есть **mailhog** для просмотра почты. http://localhost:8025/

## Поддерживаются в любом сочетании:

PHP: 7.3, 7.4
MySql: 5.7, 8

## Установка

Клонируем проект

`git clone http://bitbucket.zebrains.team/scm/mb24/b_docker.git`

Запускаем команду копирования служебных файлов

`make copyinitdata`

Настраиваем окружение в файле `.env`
`NGINX_HOST` должен совпадать с настройками Главного модуля, URL сайта (без http://, например www.mysite.com)

Запускаем docker
`make dc-up`

устанавливаем битрикс:
`http://localhost/bitrixsetup.php` - если проект новый.
`http://localhost/restore.php` - если восстанавливаем из бекапа битрикса.

Удаляем git и мусор, после установки 1C-Битрикс.
`make setupclear` ---   Подразумевается использование: под каждый проект - свой git.

## Структура проекта
-- **bash_history** - папка для хранения истории bash контейнеров
-- **conf** - конфиги. ngnix и пр.
-- **dumps** - папка для дампов БД
-- **images** - папка с docker образами
-- **initdata** - папка с служебными файлами
-- **www** - root дериктория проекта
-- .env-exeplame - пример файла `.env`
-- .gitignore - список игнора
-- Makefile - команды make. Список команд make можно посмотреть так: `make` или `make help`
-- docker-compose.yml - конфиг контейнеров
-- readmy.md - этот файл

## memcached
Пример хранения данных сессии в **memcached**, настройки файла `bitrix/.settings.php`
````php
return [
//...        
    'session' => [
        'value' => [
            'mode' => 'default',
            'handlers' => [
                'general' => [
                    'type' => 'memcache',   
    			    'host' => 'memcached',
    			    'port' => '11211',
                ],           
            ],
        ]                   
    ] 
];
````
Подробней в https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=43&LESSON_ID=14026&LESSON_PATH=3913.3435.4816.14028.14026

## TODO List
Сборка с PHP 8.0
