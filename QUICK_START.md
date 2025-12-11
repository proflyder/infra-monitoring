# Quick Start

## Первый запуск

### 1. Настройка VPS
```bash
scp scripts/setup-vps.sh root@vps_ip:/tmp/
ssh root@vps_ip "bash /tmp/setup-vps.sh"
```

### 2. Настройка GitHub Secrets
```bash
# Генерация SSH ключа
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github_deploy_key -N ""

# Добавь публичный ключ на VPS
cat ~/.ssh/github_deploy_key.pub
ssh root@vps_ip
sudo su - github-ci-cd-integration
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "PASTE_KEY" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

**GitHub → Settings → Secrets → Actions:**
```
SSH_PRIVATE_KEY    = содержимое ~/.ssh/github_deploy_key
SSH_HOST           = IP адрес VPS
SSH_USER           = github-ci-cd-integration
GRAFANA_ADMIN_PASSWORD = openssl rand -base64 32
```

**Подробно:** [docs/GITHUB_SECRETS_SETUP.md](docs/GITHUB_SECRETS_SETUP.md)

### 3. Деплой
```bash
git push origin master
# GitHub Actions → Build → Deploy → Smoke tests
```

### 4. Настройка nginx
```bash
ssh github-ci-cd-integration@vps_ip
sudo nano /etc/nginx/sites-available/proflyder.dev
# Добавь location из config/nginx-default-full.conf
sudo nginx -t && sudo systemctl reload nginx
```

### 5. Открой Grafana
```
URL: https://proflyder.dev/grafana/
Login: admin
Password: из GRAFANA_ADMIN_PASSWORD
```

### 6. Grafana API Key (опционально)
После первого деплоя:
1. **Administration** → **Service accounts** → **Add service account**
2. Name: `GitHub Actions Deploy`, Role: `Editor`
3. **Add token** → Скопируй
4. GitHub Secrets → `GRAFANA_API_KEY` = токен

**Подробно:** [docs/GRAFANA_API_SETUP.md](docs/GRAFANA_API_SETUP.md)

---

## Production release (Semantic Versioning)

```bash
git tag -a v1.0.0 -m "Production release 1.0.0"
git push origin v1.0.0
# Создаст образы: v1.0.0, 1.0, latest
```

---

## Rollback

### Автоматический
При ошибке деплоя или smoke tests workflow откатится автоматически.

### Ручной
```bash
# На VPS
cat /opt/monitoring/DEPLOYED_VERSION.backup
PREV_IMAGE=$(grep "^Image:" /opt/monitoring/DEPLOYED_VERSION.backup | cut -d' ' -f2)
sudo docker pull "$PREV_IMAGE"
sudo docker run --rm -v /opt/monitoring:/output "$PREV_IMAGE"
cd /opt/monitoring && sudo docker compose restart
```

**Подробно:** [docs/GHCR_DEPLOYMENT.md](docs/GHCR_DEPLOYMENT.md)

---

## Troubleshooting

### Деплой failed
```bash
# GitHub → Actions → последний run → смотри логи
# Проверь Secrets: Settings → Secrets → Actions
```

### Grafana не открывается
```bash
ssh github-ci-cd-integration@vps_ip
sudo docker compose -f /opt/monitoring/docker-compose.yml ps
sudo docker compose -f /opt/monitoring/docker-compose.yml logs grafana
sudo nginx -t
```

### Логи не появляются
```bash
# Проверь Loki
curl http://localhost:3100/ready

# Проверь Grafana datasource
# Grafana → Connections → Data sources → Loki → Test
```

---

## Полезные команды

```bash
# Статус
cd /opt/monitoring && sudo docker compose ps

# Логи
sudo docker compose logs -f grafana

# Перезапуск
sudo docker compose restart

# Текущая версия
cat /opt/monitoring/DEPLOYED_VERSION

# Ручная очистка
sudo docker image prune -a --filter "until=720h" --force
```

---

## Документация

- [GITHUB_SECRETS_SETUP.md](docs/GITHUB_SECRETS_SETUP.md) - Настройка GitHub Secrets
- [GHCR_DEPLOYMENT.md](docs/GHCR_DEPLOYMENT.md) - Деплой через GHCR
- [GRAFANA_API_SETUP.md](docs/GRAFANA_API_SETUP.md) - API ключ для annotations
- [GRAFANA_CONFIGURATION.md](docs/GRAFANA_CONFIGURATION.md) - Конфигурация Grafana

---

## Что работает автоматически

✅ Деплой при push в master (с concurrency control)
✅ Build Docker образа в GHCR
✅ Smoke tests после деплоя
✅ Rollback при ошибках + smoke tests после rollback
✅ Annotations в Grafana (деплой + rollback)
✅ Очистка образов после деплоя (старые config images)
✅ Очистка образов еженедельно (каждое воскресенье 00:00 UTC)
✅ Semantic Versioning (при git tag)
✅ Детальное логирование версий
