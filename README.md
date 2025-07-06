# Docker: Flask + Nginx + MySQL - Полная ручная настройка
## Учебный проект
## Структура проекта

```
docker-project/
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── nginx/
│   ├── nginx.conf
│   └── Dockerfile
├── mysql/
│   └── init.sql
└── docker-compose.yml (опционально для сравнения)
```

## 1. Flask приложение

### app/app.py
### app/requirements.txt
### app/Dockerfile

## 2. Nginx конфигурация
### nginx/nginx.conf
### nginx/Dockerfile

## 3. MySQL настройка
### mysql/init.sql

## 4. Пошаговая ручная настройка

### Шаг 1: Создание сети
```bash
# Создаем custom bridge сеть
docker network create --driver bridge myapp-network

# Проверяем созданную сеть
docker network ls
docker network inspect myapp-network
```

### Шаг 2: Запуск MySQL контейнера
```bash
# Запускаем MySQL
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

# Проверяем статус
docker ps
docker logs mysql-container

# Ждем пока MySQL полностью запустится
echo "Ждем запуска MySQL..."
sleep 30
```

### Шаг 3: Сборка и запуск Flask приложения
```bash
# Собираем образ Flask приложения
docker build -t my-flask-app ./app/

# Запускаем Flask контейнер
docker run -d \
  --name flask-container \
  --network myapp-network \
  -e DB_HOST=mysql-container \
  -e DB_USER=myuser \
  -e DB_PASSWORD=mypassword \
  -e DB_NAME=myapp \
  -p 5000:5000 \
  my-flask-app

# Проверяем логи
docker logs flask-container
```

### Шаг 4: Сборка и запуск Nginx
```bash
# Собираем образ Nginx
docker build -t my-nginx ./nginx/

# Запускаем Nginx контейнер
docker run -d \
  --name nginx-container \
  --network myapp-network \
  -p 80:80 \
  my-nginx

# Проверяем логи
docker logs nginx-container
```

### Шаг 5: Проверка работы системы
```bash
# Проверяем все контейнеры
docker ps

# Проверяем сеть
docker network inspect myapp-network

# Тестируем приложение
curl http://localhost/
curl http://localhost/health
curl http://localhost/users

# Добавляем нового пользователя
curl -X POST http://localhost/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Тест Тестов", "email": "test@example.com"}'
```

## 5. Отладка и мониторинг

### Проверка подключений между контейнерами
```bash
# Заходим в Flask контейнер и проверяем сеть
docker exec -it flask-container bash

# Внутри контейнера проверяем доступность MySQL
ping mysql-container
nslookup mysql-container

# Заходим в Nginx контейнер
docker exec -it nginx-container sh

# Проверяем доступность Flask
wget -qO- http://flask-container:5000/health
```

### Просмотр логов
```bash
# Логи каждого сервиса
docker logs -f mysql-container
docker logs -f flask-container  
docker logs -f nginx-container

# Все логи одновременно (в разных терминалах)
docker logs -f mysql-container &
docker logs -f flask-container &
docker logs -f nginx-container &
```

### Подключение к MySQL для отладки
```bash
# Подключаемся к MySQL
docker exec -it mysql-container mysql -u myuser -pmypassword myapp

# SQL команды для проверки
SHOW TABLES;
SELECT * FROM users;
DESCRIBE users;
```

## 6. Управление контейнерами

### Остановка системы
```bash
# Остановка контейнеров
docker stop nginx-container flask-container mysql-container

# Удаление контейнеров
docker rm nginx-container flask-container mysql-container

# Удаление сети
docker network rm myapp-network

# Удаление образов (опционально)
docker rmi my-nginx my-flask-app mysql:8.0
```

### Перезапуск отдельных сервисов
```bash
# Перезапуск только Flask приложения
docker stop flask-container
docker rm flask-container
docker run -d \
  --name flask-container \
  --network myapp-network \
  -e DB_HOST=mysql-container \
  -e DB_USER=myuser \
  -e DB_PASSWORD=mypassword \
  -e DB_NAME=myapp \
  -p 5000:5000 \
  my-flask-app
```

## 7. Полезные команды для диагностики

```bash
# Информация о ресурсах
docker stats

# Детальная информация о контейнере
docker inspect mysql-container

# Процессы внутри контейнера
docker top flask-container

# Использование дискового пространства
docker system df

# Очистка неиспользуемых ресурсов
docker system prune -f
```

## Объяснение ключевых моментов

1. **Сеть**: Создали custom bridge сеть для изоляции и именования контейнеров
2. **Зависимости**: Flask приложение ждет готовности MySQL с повторными попытками
3. **Переменные окружения**: Используем для конфигурации без хардкода
4. **Безопасность**: Создаем непривилегированных пользователей в контейнерах
5. **Логирование**: Настроили логи для отладки
6. **Health checks**: Добавили эндпоинты для проверки состояния

Этот пример показывает полную ручную настройку Docker окружения без docker-compose, с пониманием каждого шага!