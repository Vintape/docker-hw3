# Отчёт

## 4 балла

```sh
docker build -t docker-hw3 .
docker run -d --name docker-hw3-min-app -p 127.0.0.1:8080:8000 \
  -e 'GREETING=Привет из контейнера!' docker-hw3
curl -fsS --retry 20 --retry-delay 1 --retry-all-errors http://127.0.0.1:8080/readyz
curl -fsS http://127.0.0.1:8080/
curl -fsS -X POST http://127.0.0.1:8080/increment
docker logs docker-hw3-min-app
docker rm -f docker-hw3-min-app
```

Приветствие — «Привет из контейнера!». Счётчик вырос с `0` до `1`.

```text
2026-11-22 19:55:31,835 listening port=8000 storage=sqlite
2026-11-22 19:55:32,744 http 172.17.0.1 "GET /readyz HTTP/1.1" 200 -
2026-11-22 19:55:32,755 http 172.17.0.1 "GET / HTTP/1.1" 200 -
2026-11-22 19:55:32,839 http 172.17.0.1 "POST /increment HTTP/1.1" 200 -
```

## 6 баллов

```sh
export APP_PORT=8081 GREETING='Проверка SQLite'
sqlite() { docker compose -p hw3-min-sqlite -f compose.sqlite.yaml "$@"; }
sqlite up --build -d
curl -fsS --retry 20 --retry-delay 1 --retry-all-errors http://127.0.0.1:8081/readyz
curl -fsS -X POST http://127.0.0.1:8081/increment
sqlite down
sqlite up -d
curl -fsS --retry 20 --retry-delay 1 --retry-all-errors http://127.0.0.1:8081/readyz
curl -fsS http://127.0.0.1:8081/
sqlite down
unset APP_PORT GREETING
```

Ответы до и после пересоздания контейнера.

```text
{"greeting": "Проверка SQLite", "count": 1, "hostname": "3571e988aeab", "storage": "sqlite"}
{"greeting": "Проверка SQLite", "count": 1, "hostname": "fa0f6b4daee7", "storage": "sqlite"}
```

## 8 баллов

```sh
cp .env.example .env
redis() { docker compose -p hw3-min-redis "$@"; }
redis up --build -d --wait
redis ps
curl -fsS http://127.0.0.1:8080/
for i in 1 2 3; do curl -fsS -X POST http://127.0.0.1:8080/increment; echo; done
redis down
redis up -d --wait
curl -fsS http://127.0.0.1:8080/

before=$(redis ps -q app)
docker inspect --format '{{.State.StartedAt}}' "$before"
redis stop redis
curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8080/healthz
curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8080/readyz
curl -sS -o /dev/null -w '%{http_code}\n' -X POST http://127.0.0.1:8080/increment
redis start redis
curl -fsS --retry 20 --retry-delay 1 --retry-all-errors http://127.0.0.1:8080/readyz
curl -fsS http://127.0.0.1:8080/
curl -fsS -X POST http://127.0.0.1:8080/increment
after=$(redis ps -q app)
test "$before" = "$after"
docker inspect --format '{{.State.StartedAt}}' "$after"
redis down
```

- Оба сервиса получили статус `healthy`. После трёх POST и пересоздания контейнеров счётчик сохранил значение `3`.
- При остановленном Redis `GET /healthz` вернул `200`, `GET /readyz` и `POST /increment` вернули `503`.
- После запуска Redis GET вернул `3`, POST — `4`. ID и время запуска `app` совпали.
