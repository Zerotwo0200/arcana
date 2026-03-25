# ✦ ARCANA — Tarot Reading App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-0.111-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Minikube-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)

*Мобильное приложение для раскладов Таро с красивыми анимациями и сохранением истории*

</div>

---

## ✨ Возможности

- 🃏 **Три типа раскладов** — Карта дня, Три карты (Прошлое·Настоящее·Будущее), Пять карт
- 🌀 **Анимация переворота карт** — плавный 3D-флип при выборе
- 🔮 **Толкование расклада** — уникальные тексты для каждой из 22 карт в двух ориентациях
- 📜 **История раскладов** — все прошлые расклады сохраняются, swipe для удаления
- 👤 **Профиль** — статистика, карта дня (меняется каждый день), ваша любимая карта
- 🔐 **Авторизация** — регистрация и вход через JWT-токены
- ☸️ **Kubernetes** — полноценный деплой с автомасштабированием

---

## 📱 Скриншоты

| Расклад | Результат | Профиль |
|:---:|:---:|:---:|
| Выбор карт из колоды | Толкование с анимацией | Статистика и карта дня |

---

## 🏗 Архитектура

```
┌─────────────────────────────────────────────┐
│              Flutter (Web / Android)         │
│  welcome → home → spread → result / history  │
└──────────────────┬──────────────────────────┘
                   │ HTTP + JWT
┌──────────────────▼──────────────────────────┐
│         Kubernetes Cluster (Minikube)        │
│  ┌─────────┐  ┌──────────────────────────┐  │
│  │ Ingress │→ │  FastAPI  (2–5 реплик)   │  │
│  └─────────┘  └──────────────┬───────────┘  │
│               ┌──────────────▼───────────┐  │
│               │  PostgreSQL (StatefulSet) │  │
│               └──────────────────────────┘  │
└─────────────────────────────────────────────┘
```

### Kubernetes объекты
| Объект | Назначение |
|---|---|
| `Namespace` | Изолированное пространство `arcana` |
| `Deployment` | API-сервер, 2 реплики с rolling update |
| `StatefulSet` | PostgreSQL с сохранением состояния |
| `PersistentVolumeClaim` | Хранилище для базы данных (1Гб) |
| `Service` (ClusterIP) | Внутренняя сеть между подами |
| `Ingress` | Точка входа, маршрутизация на `arcana.local` |
| `ConfigMap` | Конфиги окружения (имя БД, URL) |
| `Secret` | Зашифрованные данные (пароли, JWT-ключ) |
| `HPA` | Автомасштаб по CPU: от 2 до 5 подов |

---

## 🗂 Структура проекта

```
arcana/
├── backend/                  # FastAPI сервер
│   ├── routers/
│   │   ├── auth.py           # Регистрация, логин, JWT
│   │   └── readings.py       # CRUD раскладов
│   ├── interpretations.py    # База толкований 22 карт
│   ├── models.py             # SQLAlchemy модели (User, Reading)
│   ├── database.py           # Подключение к PostgreSQL
│   ├── main.py               # Точка входа, CORS
│   ├── requirements.txt
│   └── Dockerfile
│
├── frontend/                 # Flutter приложение
│   └── lib/
│       ├── data/             # Данные карт Таро
│       ├── services/         # HTTP-клиент, авторизация
│       ├── widgets/          # Виджет карты с 3D-анимацией
│       ├── screens/          # Экраны приложения
│       └── main.dart
│
├── k8s/                      # Kubernetes манифесты
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── postgres.yaml
│   ├── api.yaml
│   └── ingress-hpa.yaml
│
├── docker-compose.yml        # Локальная разработка
└── README.md
```

---

## 🚀 Быстрый старт

### Требования

| Инструмент | Версия | Ссылка |
|---|---|---|
| Docker Desktop | 4.x+ | [скачать](https://www.docker.com/products/docker-desktop) |
| Flutter SDK | 3.x+ | [скачать](https://docs.flutter.dev/get-started/install/windows/web) |
| Git | любая | [скачать](https://git-scm.com/download/win) |

> После установки Flutter добавь `C:\flutter\bin` в переменную PATH

---

### 1. Клонировать репозиторий

```bash
git clone https://github.com/ТВО_НИК/arcana.git
cd arcana
```

### 2. Запустить бэкенд

```bash
docker compose up --build
```

Проверь что работает: [http://localhost:8000/health](http://localhost:8000/health)  
Документация API: [http://localhost:8000/docs](http://localhost:8000/docs)

### 3. Запустить Flutter

```bash
cd frontend
flutter pub get
flutter run -d chrome          # веб-версия
flutter run -d emulator-5554   # Android эмулятор
```

---

## ☸️ Деплой в Kubernetes

```bash
# Запустить Minikube
minikube start --driver=docker
minikube addons enable ingress
minikube addons enable metrics-server

# Собрать образ внутри Minikube
minikube docker-env | Invoke-Expression          # Windows PowerShell
docker build -t arcana-api:latest ./backend

# Применить манифесты
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/api.yaml
kubectl apply -f k8s/ingress-hpa.yaml

# Проверить статус
kubectl get all -n arcana
```

Добавь в hosts файл (PowerShell от администратора):
```powershell
Add-Content C:\Windows\System32\drivers\etc\hosts "$(minikube ip)  arcana.local"
```

API будет доступен по адресу: `http://arcana.local`

---

## 🛠 Полезные команды

```bash
# Логи API
kubectl logs -n arcana -l app=arcana-api -f

# Статус автомасштабирования
kubectl get hpa -n arcana

# Зайти в PostgreSQL
kubectl exec -it -n arcana postgres-0 -- psql -U arcana -d arcana_db

# Остановить Docker
docker compose down

# Остановить Minikube
minikube stop
```

---

## 🔌 API Endpoints

| Метод | Путь | Описание |
|---|---|---|
| `GET` | `/health` | Проверка состояния сервера |
| `POST` | `/auth/register` | Регистрация нового пользователя |
| `POST` | `/auth/login` | Вход, получение JWT-токена |
| `GET` | `/auth/me` | Данные текущего пользователя |
| `POST` | `/readings/` | Создать новый расклад |
| `GET` | `/readings/` | История раскладов пользователя |
| `GET` | `/readings/{id}` | Конкретный расклад |
| `DELETE` | `/readings/{id}` | Удалить расклад |

---

## 🃏 Карты Таро

Приложение включает все **22 старших аркана** с толкованиями в прямой и перевёрнутой позиции:

`Шут` · `Маг` · `Жрица` · `Императрица` · `Император` · `Иерофант` · `Влюблённые` · `Колесница` · `Сила` · `Отшельник` · `Колесо Судьбы` · `Справедливость` · `Повешенный` · `Смерть` · `Умеренность` · `Дьявол` · `Башня` · `Звезда` · `Луна` · `Солнце` · `Суд` · `Мир`

---

## 📦 Технологии

**Frontend**
- [Flutter](https://flutter.dev) — кроссплатформенный UI-фреймворк
- [Provider](https://pub.dev/packages/provider) — управление состоянием
- [flutter_animate](https://pub.dev/packages/flutter_animate) — анимации
- [google_fonts](https://pub.dev/packages/google_fonts) — шрифты Cinzel, Cormorant Garamond
- [shared_preferences](https://pub.dev/packages/shared_preferences) — локальное хранилище токена

**Backend**
- [FastAPI](https://fastapi.tiangolo.com) — REST API фреймворк
- [SQLAlchemy](https://sqlalchemy.org) — ORM для работы с БД
- [PostgreSQL](https://postgresql.org) — реляционная база данных
- [passlib + bcrypt](https://passlib.readthedocs.io) — хэширование паролей
- [python-jose](https://python-jose.readthedocs.io) — JWT-токены

**Инфраструктура**
- [Docker](https://docker.com) — контейнеризация
- [Kubernetes](https://kubernetes.io) — оркестрация (Minikube)

---

<div align="center">

*Сделано с ✦ и Flutter*

</div>
