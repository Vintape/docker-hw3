# ДЗ 3 по Docker

В `.env` задаются `APP_PORT` (внешний порт, по умолчанию `8080`) и `GREETING` (приветствие).

```sh
cp .env.example .env
```

## Redis

```sh
docker compose up --build -d --wait
```

## SQLite

```sh
docker compose -f compose.sqlite.yaml up --build -d
```

[Отчёт о проверках](REPORT.md)
