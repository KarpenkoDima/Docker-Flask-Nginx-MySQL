<div align="center">

# Docker: Flask + Nginx + MySQL

**Трёхуровневое веб-приложение в Docker-контейнерах**

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)](https://flask.palletsprojects.com/)
[![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)](https://nginx.org/)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Python](https://img.shields.io/badge/Python_3.11-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

---

*Учебный проект, демонстрирующий контейнеризацию микросервисной архитектуры*

</div>

## Архитектура

```
                  ┌─────────────────────────────────────────────┐
                  │              Docker Network                  │
                  │           (myapp-network)                    │
                  │                                             │
 Client ──────►  │  ┌─────────┐    ┌─────────┐    ┌─────────┐ │
  :8080          │  │  Nginx  │───►│  Flask  │───►│  MySQL  │ │
                  │  │  :8080  │    │  :5000  │    │  :3306  │ │
                  │  └─────────┘    └─────────┘    └─────────┘ │
                  │   reverse        REST API       database    │
                  │   proxy                                     │
                  └─────────────────────────────────────────────┘
```

## Структура проекта

```
Docker-Flask-Nginx-MySQL/
├── app/
│   ├── app.py               # Flask REST API приложение
│   ├── requirements.txt     # Python зависимости
│   ├── Dockerfile           # Образ для Flask
│   └── .dockerignore        # Исключения для Docker
├── nginx/
│   ├── nginx.conf           # Конфигурация reverse proxy
│   ├── Dockerfile           # Образ для Nginx
│   └── .dockerignore        # Исключения для Docker
├── mysql/
│   └── init.sql             # Инициализация БД и тестовые данные
├── docker-compose.yml       # Оркестрация всех сервисов
├── Makefile                 # Удобные команды управления
├── .env.example             # Шаблон переменных окружения
├── .gitignore               # Исключения для Git
├── LICENSE                  # MIT лицензия
└── README.md
```

## Быстрый старт

### Требования

- [Docker](https://docs.docker.com/get-docker/) >= 20.10
- [Docker Compose](https://docs.docker.com/compose/install/) >= 2.0

### Запуск

```bash
# 1. Клонируйте репозиторий
git clone https://github.com/KarpenkoDima/Docker-Flask-Nginx-MySQL.git
cd Docker-Flask-Nginx-MySQL

# 2. (Опционально) Настройте переменные окружения
cp .env.example .env
# Отредактируйте .env при необходимости

# 3. Запустите все сервисы
docker compose up -d --build

# 4. Проверьте статус
docker compose ps
```

Приложение будет доступно на `http://localhost:8080`

## API Endpoints

| Метод  | URL             | Описание                    |
|--------|-----------------|-----------------------------|
| `GET`  | `/`             | Health check приложения     |
| `GET`  | `/health`       | Проверка подключения к БД   |
| `GET`  | `/users`        | Получить всех пользователей |
| `POST` | `/users`        | Добавить пользователя       |
| `GET`  | `/nginx-health` | Health check Nginx          |

### Примеры запросов

```bash
# Проверка работы
curl http://localhost:8080/

# Статус БД
curl http://localhost:8080/health

# Список пользователей
curl http://localhost:8080/users

# Добавить пользователя
curl -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Тест Тестов", "email": "test@example.com"}'
```

## Makefile команды

```bash
make help           # Показать все доступные команды
make up             # Запустить все сервисы
make down           # Остановить все сервисы
make build          # Пересобрать и запустить
make restart        # Перезапустить сервисы
make logs           # Логи всех сервисов
make logs-flask     # Логи Flask
make logs-nginx     # Логи Nginx
make logs-mysql     # Логи MySQL
make status         # Статус контейнеров
make shell-flask    # Shell в Flask контейнере
make shell-mysql    # MySQL CLI
make test           # Тест API endpoints
make clean          # Остановить и удалить volumes
```

## Стек технологий

| Компонент    | Технология       | Версия  | Назначение              |
|--------------|------------------|---------|-------------------------|
| Web-сервер   | Nginx            | Alpine  | Reverse proxy           |
| Backend      | Flask            | 2.3.3   | REST API                |
| Язык         | Python           | 3.11    | Среда выполнения        |
| База данных  | MySQL            | 8.0     | Хранение данных         |
| Контейнеры   | Docker           | latest  | Контейнеризация         |
| Оркестрация  | Docker Compose   | v2      | Управление сервисами    |

## Ручная настройка (без Docker Compose)

<details>
<summary><b>Развернуть инструкцию по ручному запуску</b></summary>

### Шаг 1: Создание сети

```bash
docker network create --driver bridge myapp-network
docker network ls
```

### Шаг 2: Запуск MySQL

```bash
docker run -d \
  --name mysql-container \
  --network myapp-network \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=myapp \
  -e MYSQL_USER=myuser \
  -e MYSQL_PASSWORD=mypassword \
  -v $(pwd)/mysql/init.sql:/docker-entrypoint-initdb.d/init.sql \
  -p 3306:3306 \
  mysql:8.0

# Ждём пока MySQL полностью запустится
echo "Ждём запуска MySQL..."
sleep 30
docker logs mysql-container
```

### Шаг 3: Сборка и запуск Flask

```bash
docker build -t my-flask-app ./app/

docker run -d \
  --name flask-container \
  --network myapp-network \
  -e DB_HOST=mysql-container \
  -e DB_USER=myuser \
  -e DB_PASSWORD=mypassword \
  -e DB_NAME=myapp \
  -p 5000:5000 \
  my-flask-app

docker logs flask-container
```

### Шаг 4: Сборка и запуск Nginx

```bash
docker build -t my-nginx ./nginx/

docker run -d \
  --name nginx-container \
  --network myapp-network \
  -p 8080:8080 \
  my-nginx

docker logs nginx-container
```

### Шаг 5: Проверка

```bash
docker ps
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/users
```

### Остановка и удаление

```bash
docker stop nginx-container flask-container mysql-container
docker rm nginx-container flask-container mysql-container
docker network rm myapp-network
```

</details>

## Отладка

<details>
<summary><b>Полезные команды для диагностики</b></summary>

### Логи сервисов

```bash
docker compose logs -f              # Все сервисы
docker compose logs -f flask        # Только Flask
docker compose logs -f mysql        # Только MySQL
docker compose logs -f nginx        # Только Nginx
```

### Подключение к контейнерам

```bash
# Flask shell
docker compose exec flask bash

# Nginx shell
docker compose exec nginx sh

# MySQL CLI
docker compose exec mysql mysql -u myuser -pmypassword myapp
```

### Проверка подключений

```bash
# Из Flask контейнера
docker compose exec flask bash -c "ping -c 3 mysql-container"

# Из Nginx контейнера
docker compose exec nginx wget -qO- http://flask-container:5000/health
```

### Мониторинг ресурсов

```bash
docker stats                    # Использование CPU/RAM
docker compose ps               # Статус контейнеров
docker system df                # Дисковое пространство
```

</details>

## Ключевые решения

- **Custom bridge network** -- изоляция сервисов и DNS-резолвинг по имени контейнера
- **Health checks** -- MySQL healthcheck в docker-compose гарантирует, что Flask запустится только после готовности БД
- **Retry-логика** -- Flask приложение повторяет подключение к БД до 10 раз с интервалом 2 секунды
- **Unprivileged users** -- контейнеры работают от непривилегированных пользователей (`appuser`, `nginx`)
- **Переменные окружения** -- конфигурация через `.env` файл без хардкода

## Лицензия

Этот проект распространяется под лицензией [MIT](LICENSE).
