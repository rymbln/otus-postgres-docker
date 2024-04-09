# Postgres + Docker

## Простой запуск

```bash
docker run --name otus-pg -e POSTGRES_PASSWORD=password -d postgres
```

Подключимся к контейнеру

```bash
docker exec -it otus-pg psql --username=postgres --dbname=postgres
```

Посмотрим, какие базы данных есть

```
\list
```

Закроем подключение

```
\q
```

При таком запуске мы не сможем подключаться из внешних сервисов, и все данные будут удалены после остановки контейнера.
Добавим порты и место сохранения данных

```bash
docker run --name otus-pg \
-p 5432:5432 \
-v ./data:/var/lib/postgresql/data \
-e POSTGRES_PASSWORD=password \
-d postgres:16
```

Добавим также определение пользователя и базы данных

```bash
docker run --name otus-pg \
-p 5432:5432 \
-v ./data:/var/lib/postgresql/data \
-e POSTGRES_PASSWORD=otuspassword \
-e POSTGRES_USER=otususer \
-e POSTGRES_DB=otusdb \
-d postgres:16
```

Теперь уже подключаемся с нормальным пользователем

```bash
docker exec -it otus-pg psql --username=otususer --dbname=otusdb
```

Посмотрим, какие базы данных есть

```
\list
```

## Инициализация структуры

```bash
docker run --name otus-pg \
-p 5432:5432 \
-v ./data:/var/lib/postgresql/data \
-v ./init:/docker-entrypoint-initdb.d \
-e POSTGRES_PASSWORD=otuspassword \
-e POSTGRES_USER=otususer \
-e POSTGRES_DB=otusdb \
-d postgres:16
```

Подключаемся

```bash
docker exec -it otus-pg psql --username=otususer --dbname=otusdb
```

Проверим доступные расширения

```sql
SELECT * FROM pg_extension;
```

Посмотрим, какие базы данных есть

```
\list
```

Посмотрим, что есть в базе данных otusdb

```
\c otusdb
\dt
select * from people limit 10;
```

Список всех переменных окружения доступен по ссылке:
- https://github.com/docker-library/docs/blob/master/postgres/README.md

## Docker compose

Простой запуск

```bash
docker compose -f 01-postgres.yml up -d
```

Здесь можно также примонтировать и папку для сохранения бекапов, потому что при запуске pgdump она будет запускаться внутри контейнера

```bash
docker exec -it postgres pg_dumpall -U otususer -f /backups/dump.sql
```

Альтернативным вариантом может быть вывод через пайп

```bash
docker exec -it postgres pg_dump -U otususer -d otusdb > otusdb.sql
```

Про docker compose:
- https://docs.docker.com/compose/compose-file/

Про тома (volumes) и их настройку:
- https://docs.docker.com/compose/compose-file/07-volumes/

Про утилиты для бекапов:
- https://linuxhint.com/pg-dump-postgresql/
- https://www.postgresql.org/docs/current/app-pgdump.html
- https://www.postgresql.org/docs/current/app-pg-dumpall.html


## Настройка параметров в docker-compose

- Порты, тома, переменные окружения
- Политики перезапуска
- Проверки Healthcheck - Основная задача – как можно скорее уведомить среду, управляющую контейнером, о том, что с контейнером что-то не так. И самая простая стратегия решения проблемы – перезапуск контейнера.
- Ограничение ресурсов

Простой запуск `02-health.yml`.

```bash
docker compose -f 02-health.yml up -d
```

## Настройка параметров базы данных

```bash
docker exec -it postgres psql --username=otususer --dbname=otusdb
```

Посмотреть список установленных расширений можно с помощью запроса `select * from pg_extension;`.

Команда show позволит узнать текущее значение того или иного параметра, например: `show random_page_cost;`.

Настройки можно задавать через команды при запуске

```bash
docker compose -f 03-settings.yml up -d
```

Можно сделать проще и указать сразу файл конфигурации

```bash
docker compose -f 04-config.yml up -d
```

Команда show позволит узнать текущее значение того или иного параметра, например: `show random_page_cost;`.

```bash
docker exec -it postgres psql --username=otususer --dbname=otusdb -c "show max_connections;"
```

## Запуск нескольких сервисов сразу

Преимуществом docker-compose является возможность одновременного запуска сразу нескольких сервисов, которые могут взаимодействовать с собой. Они могут обращаться к друг другу по имени контейнера и работать в одной внутренней изолированной сети.

- pgAdmin - графический клиент для работы с сервером
- pgbouncer - управление пулом соединений
- prometheus - база данных для сбора метрик
- postgres-exporter - поставщик метрик postgres для prometheus
- grafana - визуализация метрик в красивых дашбордах

```bash
docker compose -f 05-monitoring.yml up -d
```

PgAdmin

http://localhost:5050

Проверка метрики

http://localhost:9187/metrics

Grafana

http://localhost:3000

Настройка Prometheus и Grafana

- https://mxulises.medium.com/prometheus-integration-with-grafana-c91059ee8314

Дашборды

- https://grafana.com/grafana/dashboards/9628-postgresql-database/
- https://grafana.com/grafana/dashboards/14114-postgres-overview/
- https://grafana.com/grafana/dashboards/12273-postgresql-overview-postgres-exporter/


### Bitnami

Попробуем поднять небольшой кластер с помощью образа от bitnami, который включает в себя сразу Postgres и repmgr от EnterpriseDB.

```bash
docker compose -f 06-bitnami.yml up -d
```

Посмотрим, что есть на мастере

```bash
docker exec postgres_1 psql -c "select * from people order by id desc limit 10;" "dbname=otusdb user=otususer password=otuspassword"
```

Посмотрим, что есть на реплике

```bash
docker exec postgres_2 psql -c "select * from people order by id desc limit 10;" "dbname=otusdb user=otususer password=otuspassword"
```

Добавим запись на мастер

```bash
docker exec postgres_1 psql -c "insert into people (id, first_name, last_name, email, gender, ip_address) values (1001, 'John', 'Doe', 'johndoe@example.com', 'Male', '127.0.0.1')" "dbname=otusdb user=otususer password=otuspassword"
```

Удалим записи на мастере

```bash
docker exec postgres_1 psql -c "delete from people where id < 1000" "dbname=otusdb user=otususer password=otuspassword"
```

Останавливаем `postgres_1`

```bash
docker stop postgres_1
docker logs postgres_2
```

После этого реплика становится мастером и может принимать запросы на запись.

Запускаем `postgres_1`

```bash
docker start postgres_1
docker logs postgres_2
docker logs postgres_1
```

Он поднимется, увидит, что есть новый мастер, и продолжит функционировать как реплика.

Чтобы понять в какой роли функционирует конкретный хост, можно воспользоваться запросом.

```bash
docker exec postgres_1 psql -c "select case when pg_is_in_recovery() then 'secondary' else 'primary' end as host_status;" "dbname=otusdb user=otususer password=otuspassword"

docker exec postgres_2 psql -c "select case when pg_is_in_recovery() then 'secondary' else 'primary' end as host_status;" "dbname=otusdb user=otususer password=otuspassword"

```

Полезные материалы:

- https://github.com/bitnami/containers/blob/main/bitnami/postgresql/README.md
- https://github.com/bitnami/containers/tree/main/bitnami/postgresql-repmgr
- https://docs.bitnami.com/general/infrastructure/postgresql/
- https://github.com/deepmap/bitnami-docker-postgresql-repmgr
- https://www.repmgr.org/docs/current/
- https://habr.com/ru/articles/754168/



