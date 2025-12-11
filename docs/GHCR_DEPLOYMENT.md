# Деплой через GHCR

## Как работает

```
GitHub Actions → Docker build → GHCR → VPS pull → deploy
```

### Преимущества
- ✅ Версионирование конфигов (каждый commit = образ)
- ✅ Автоматический rollback при ошибках
- ✅ Отслеживание версий на VPS (DEPLOYED_VERSION файл)
- ✅ Комплексные smoke tests
- ✅ Grafana annotations
- ✅ Кеширование Docker слоев

---

## Workflow

### 1. Build job
```yaml
- Checkout кода
- Login в ghcr.io
- Build образа из Dockerfile
- Push в ghcr.io/username/infra-monitoring-config:latest
```

### 2. Deploy job
```yaml
1. Backup текущей версии (DEPLOYED_VERSION.backup)
2. Pull образа из GHCR
3. Извлечение конфигов в /opt/monitoring
4. Создание DEPLOYED_VERSION с инфо о версии
5. docker compose up -d
6. Smoke tests (проверка всех сервисов + логин в Grafana)
7. При ошибке → rollback на предыдущую версию
```

---

## Использование

### Автоматический деплой
```bash
git push origin master
# Автоматически: build → push GHCR → deploy → smoke tests
```

### Ручной rollback
```bash
# Посмотри DEPLOYED_VERSION.backup
cat /opt/monitoring/DEPLOYED_VERSION.backup

# Извлеки предыдущий образ
PREVIOUS_IMAGE=$(grep "^Image:" /opt/monitoring/DEPLOYED_VERSION.backup | cut -d' ' -f2)
sudo docker pull "$PREVIOUS_IMAGE"
sudo docker run --rm -v /opt/monitoring:/output "$PREVIOUS_IMAGE"
cd /opt/monitoring && sudo docker compose restart
```

### Проверка текущей версии
```bash
cat /opt/monitoring/DEPLOYED_VERSION
```

### Локальное тестирование
```bash
docker build -t test-config .
mkdir -p /tmp/test-monitoring
docker run --rm -v /tmp/test-monitoring:/output test-config
cd /tmp/test-monitoring
echo "GRAFANA_ADMIN_PASSWORD=test123" > .env
docker compose up -d
```

---

## Troubleshooting

### Permission denied при push в GHCR
```yaml
# В workflow добавь permissions
jobs:
  build:
    permissions:
      packages: write  # ← Нужно!
```

### Login failed на VPS
```yaml
# Проверь что токен передается
envs: GITHUB_TOKEN,GITHUB_ACTOR
```

### Smoke tests провалились
Workflow автоматически откатится. Проверь логи:
```bash
sudo docker compose -f /opt/monitoring/docker-compose.yml logs
cat /opt/monitoring/DEPLOYED_VERSION  # Должна быть предыдущая версия
```

### Образ не виден в GitHub Packages
GitHub → Packages → Change visibility → Public (или оставь private с GITHUB_TOKEN)

---

## Просмотр версий

### Через GitHub UI
https://github.com/USERNAME/infra-monitoring → Packages → infra-monitoring-config

### Через API
```bash
curl -H "Authorization: Bearer TOKEN" \
  https://api.github.com/users/USERNAME/packages/container/infra-monitoring-config/versions
```

---

## Удаление старых образов

### Автоматическая очистка
- **GHCR**: Автоматически удаляет untagged образы через 14 дней
- **VPS**: Scheduled workflow каждое воскресенье в 00:00 UTC удаляет образы старше 30 дней

### Ручная очистка
```bash
# На VPS
docker image prune -a --filter "until=720h" --force

# Или запусти workflow вручную:
# GitHub → Actions → Cleanup Old Docker Images → Run workflow
```
