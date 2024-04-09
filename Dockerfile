# ВЫБИРАЕМ БАЗОВЫЙ ОБРАЗ
FROM postgres:16 as base

# Копируем скрипты инициализации
# Можно использовать *.sql, *.sql.gz, или *.sh
COPY init docker-entrypoint-initdb.d/
COPY dump docker-entrypoint-initdb.d/
# Зададим переменные окружения
# ENV POSTGRES_DB=otusdb
# ENV POSTGRES_USER=otususer
ENV POSTGRES_PASSWORD=otuspassword
# Открываем порт
EXPOSE 5432
