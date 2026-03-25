# ARCANA — Полное руководство по запуску

## Структура проекта
```
arcana/
├── backend/          ← FastAPI сервер
│   ├── main.py
│   ├── database.py
│   ├── models.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── routers/
│       ├── auth.py
│       └── readings.py
├── frontend/         ← Flutter Web приложение
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart
│       ├── data/tarot_cards.dart
│       ├── services/
│       │   ├── auth_service.dart
│       │   └── readings_service.dart
│       ├── widgets/tarot_card_widget.dart
│       └── screens/
│           ├── welcome_screen.dart
│           ├── home_screen.dart
│           ├── spread_screen.dart
│           ├── reading_result_screen.dart
│           └── history_screen.dart
├── k8s/              ← Kubernetes манифесты
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── postgres.yaml
│   ├── api.yaml
│   └── ingress-hpa.yaml
└── docker-compose.yml
```

---

## ЭТАП 1 — Установка инструментов (Windows)

### 1.1 Flutter SDK
Открой PowerShell от администратора:
```powershell
winget install Google.Flutter
# Перезапусти PowerShell, затем:
flutter --version
flutter config --enable-web
```

### 1.2 VS Code
```powershell
winget install Microsoft.VisualStudioCode
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
code --install-extension ms-python.python
code --install-extension ms-azuretools.vscode-docker
```

### 1.3 Minikube + kubectl
```powershell
winget install Kubernetes.minikube
winget install Kubernetes.kubectl
minikube version   # проверка
kubectl version --client
```

---

## ЭТАП 2 — Запуск бэкенда локально

### 2.1 Запусти через Docker Compose
```powershell
cd C:\projects\arcana
docker compose up --build
```

Проверь что работает:
- API: http://localhost:8000/health  →  {"status": "ok"}
- Документация: http://localhost:8000/docs  (Swagger UI)

---

## ЭТАП 3 — Запуск Flutter Web

### 3.1 Установи зависимости
```powershell
cd C:\projects\arcana\frontend
flutter pub get
```

### 3.2 Запусти в браузере
```powershell
flutter run -d chrome
```

Flutter откроет Chrome. Зарегистрируйся, войди — приложение работает!

---

## ЭТАП 4 — Деплой в Kubernetes

### 4.1 Запусти Minikube
```powershell
minikube start --driver=docker
minikube addons enable ingress
minikube addons enable metrics-server
```

### 4.2 Собери Docker-образ ВНУТРИ Minikube
```powershell
# Переключи Docker на контекст Minikube
minikube docker-env | Invoke-Expression

# Теперь build видит Minikube изнутри
docker build -t arcana-api:latest ./backend
```

### 4.4 Примени все манифесты
```powershell
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/api.yaml
kubectl apply -f k8s/ingress-hpa.yaml
```

### 4.5 Проверь что всё запустилось
```powershell
kubectl get all -n arcana
```
Все поды должны быть в статусе Running.

### 4.6 Получи адрес Ingress
```powershell
minikube ip
# Например: 192.168.49.2
```

Добавь в C:\Windows\System32\drivers\etc\hosts:
```
192.168.49.2  arcana.local
```

Теперь API доступен по: http://arcana.local

### 4.7 Переключи Flutter на k8s-адрес
В файле frontend/lib/services/auth_service.dart замени:
```dart
static const String baseUrl = 'http://localhost:8000';
// на:
static const String baseUrl = 'http://arcana.local';
```

Пересобери Flutter:
```powershell
flutter run -d chrome
```

---

## Полезные команды

```powershell
# Посмотреть логи API
kubectl logs -n arcana -l app=arcana-api -f

# Посмотреть логи PostgreSQL
kubectl logs -n arcana -l app=postgres -f

# Посмотреть состояние HPA (автомасштаб)
kubectl get hpa -n arcana

# Войти в PostgreSQL
kubectl exec -it -n arcana postgres-0 -- psql -U arcana -d arcana_db

# Остановить всё
minikube stop
```

---

## Проверка задания ✓

| Требование          | Реализация                              |
|--------------------|-----------------------------------------|
| Мобильное приложение| Flutter Web (кросс-платформа)           |
| Клиент-сервер      | Flutter → FastAPI REST API              |
| Kubernetes         | Deployment, Service, Ingress, StatefulSet, PVC, ConfigMap, Secret, HPA |
| База данных        | PostgreSQL в StatefulSet с PVC          |
| Авторизация        | JWT токены                              |
| Основная функция   | Расклад таро + интерпретация Claude AI  |
