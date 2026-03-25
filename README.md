# ✦ ARCANA — Tarot Reading App

Мобильное приложение для раскладов Таро.
Flutter Web + FastAPI + PostgreSQL + Kubernetes.

## Что нужно установить

| Инструмент | Ссылка | Зачем |
|---|---|---|
| Docker Desktop | https://www.docker.com/products/docker-desktop | Запуск бэкенда |
| Flutter SDK | https://docs.flutter.dev/get-started/install/windows/web | Запуск фронтенда |
| Git | https://git-scm.com/download/win | Клонирование репо |

После установки Flutter добавь `C:\flutter\bin` в PATH.

## Быстрый старт

### 1. Клонируй репозиторий
```bash
git clone https://github.com/zerotwo0200/arcana.git
cd arcana
```

### 2. Запусти бэкенд
```bash
docker compose up --build
```
Проверь: http://localhost:8000/health → должно вернуть `{"status":"ok"}`

### 3. Запусти фронтенд
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

Всё — приложение откроется в браузере.

## Структура проекта
```
arcana/
├── backend/        ← FastAPI + PostgreSQL
├── frontend/       ← Flutter Web
├── k8s/            ← Kubernetes манифесты
└── docker-compose.yml
```

## Kubernetes (опционально)
```bash
minikube start --driver=docker
minikube addons enable ingress
minikube docker-env | Invoke-Expression
docker build -t arcana-api:latest ./backend
kubectl apply -f k8s/
kubectl get all -n arcana
```
