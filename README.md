# Proflyder Infrastructure Monitoring

Централизованный мониторинг и логирование для всех проектов Proflyder.

## Stack

- **Loki** - хранилище логов
- **Prometheus** - метрики
- **Node Exporter** - системные метрики VPS
- **Grafana** - визуализация

**URL:** https://proflyder.dev/grafana/

---

## Quick Start

Смотри [QUICK_START.md](QUICK_START.md)

```bash
# 1. Setup VPS
scp scripts/setup-vps.sh root@vps:/tmp/
ssh root@vps "bash /tmp/setup-vps.sh"

# 2. Setup GitHub Secrets (см. docs/GITHUB_SECRETS_SETUP.md)

# 3. Deploy
git push origin master
```

---

## Features

### CI/CD через GHCR
- ✅ Версионирование конфигов (Docker образы)
- ✅ Semantic Versioning (git tags → образы с версиями)
- ✅ Автоматический rollback при ошибках
- ✅ Smoke tests после rollback (гарантия восстановления)
- ✅ Concurrency control (предотвращение параллельных деплоев)
- ✅ Детальное логирование версий для отладки
- ✅ Отслеживание версий на VPS (`DEPLOYED_VERSION`)
- ✅ Grafana annotations (маркеры деплоев на графиках)
- ✅ Автоматическая очистка образов (после деплоя + еженедельно)

### Безопасность
- ✅ Порты только локально (127.0.0.1)
- ✅ Доступ через nginx + SSL
- ✅ Авторизация обязательна
- ✅ Регистрация отключена

### Мониторинг
- ✅ Retention: 14 дней (Loki)
- ✅ Retention: 30 дней (Prometheus)
- ✅ Системные метрики VPS (CPU, RAM, Disk, Network)
- ✅ Health checks

---

## Структура

```
infra-monitoring/
├── docker-compose.yml              # Сервисы
├── Dockerfile                      # Config image для GHCR
├── config/
│   ├── grafana/
│   │   ├── grafana.ini            # Конфиг Grafana (Proflyder, Asia/Almaty)
│   │   ├── dashboards/            # Готовые дашборды
│   │   └── provisioning/          # Datasources, dashboards
│   ├── loki-config.yml            # Конфиг Loki
│   ├── prometheus.yml             # Конфиг Prometheus
│   └── nginx-default-full.conf    # Nginx конфиг
├── .github/
│   ├── workflows/
│   │   ├── deploy.yml             # CI/CD: build → GHCR → deploy → smoke tests → rollback
│   │   └── cleanup.yml            # Очистка старых образов (weekly)
│   ├── actions/
│   │   ├── smoke-tests/           # Композитный экшен для smoke tests
│   │   └── grafana-annotation/    # Композитный экшен для Grafana аннотаций
│   └── scripts/
│       ├── backup-version.sh      # Backup текущей версии
│       ├── deploy-stack.sh        # Деплой мониторинга
│       ├── rollback-stack.sh      # Откат к предыдущей версии
│       └── cleanup-images.sh      # Очистка старых образов
├── scripts/
│   └── setup-vps.sh               # VPS setup скрипт
├── docs/                          # Документация
└── .env.example                   # Env variables
```

---

## Использование

### Grafana

**LogQL примеры:**
```logql
{job="currency-bot"}                          # Все логи проекта
{job="currency-bot"} |= "ERROR"               # Только ошибки
{job="currency-bot"} | json | level="ERROR"   # После парсинга JSON
{job="currency-bot"} |= "timeout"             # Поиск по слову
```

### Docker Compose

```bash
# На VPS
cd /opt/monitoring

# Статус
sudo docker compose ps

# Логи
sudo docker compose logs -f grafana

# Перезапуск
sudo docker compose restart

# Версия
cat DEPLOYED_VERSION
```

### Production Release

```bash
git tag -a v1.0.0 -m "Production release 1.0.0"
git push origin v1.0.0
# Создаст: v1.0.0, 1.0, latest
```

### Rollback

Автоматически при ошибках деплоя.

Ручной:
```bash
cat /opt/monitoring/DEPLOYED_VERSION.backup
PREV=$(grep "^Image:" /opt/monitoring/DEPLOYED_VERSION.backup | cut -d' ' -f2)
sudo docker pull "$PREV"
sudo docker run --rm -v /opt/monitoring:/output "$PREV"
cd /opt/monitoring && sudo docker compose restart
```

---

## Подключение проектов

Каждый проект запускает свой **Promtail** для отправки логов в Loki.

**docker-compose.yml:**
```yaml
promtail:
  image: grafana/promtail:2.9.3
  volumes:
    - ./config/promtail-config.yml:/etc/promtail/config.yml
    - /var/log/app:/var/log/app:ro
  command: -config.file=/etc/promtail/config.yml
```

**promtail-config.yml:**
```yaml
clients:
  - url: http://host.docker.internal:3100/loki/api/v1/push

scrape_configs:
  - job_name: my-app
    static_configs:
      - targets: [localhost]
        labels:
          job: my-app
          __path__: /var/log/app/*.log
```

Затем в Grafana: `{job="my-app"}`

---

## Backup

```bash
# Grafana
docker run --rm \
  -v infra-monitoring_grafana-data:/source \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/grafana-$(date +%Y%m%d).tar.gz -C /source .

# Restore
docker volume rm infra-monitoring_grafana-data
docker volume create infra-monitoring_grafana-data
docker run --rm \
  -v infra-monitoring_grafana-data:/target \
  -v $(pwd)/backups:/backup \
  alpine sh -c "cd /target && tar xzf /backup/grafana-YYYYMMDD.tar.gz"
```

То же для `loki-data` и `prometheus-data`.

---

## Troubleshooting

### Деплой failed
```bash
# GitHub → Actions → последний run
# Проверь: Settings → Secrets → Actions
```

### Grafana 502
```bash
sudo docker compose -f /opt/monitoring/docker-compose.yml ps
sudo docker compose logs grafana
sudo nginx -t
```

### Логи не появляются
```bash
curl http://localhost:3100/ready
curl 'http://localhost:3100/loki/api/v1/query?query={job="my-app"}'
docker logs promtail-my-app
```

### Нет места
```bash
docker system df -v
docker image prune -a --filter "until=720h" --force
# Или вручную запусти: GitHub → Actions → Cleanup Old Docker Images
```

---

## Документация

- [QUICK_START.md](QUICK_START.md) - Быстрый старт
- [docs/GITHUB_SECRETS_SETUP.md](docs/GITHUB_SECRETS_SETUP.md) - GitHub Secrets
- [docs/GHCR_DEPLOYMENT.md](docs/GHCR_DEPLOYMENT.md) - Деплой через GHCR
- [docs/GRAFANA_API_SETUP.md](docs/GRAFANA_API_SETUP.md) - API ключ для annotations
- [docs/GRAFANA_CONFIGURATION.md](docs/GRAFANA_CONFIGURATION.md) - Конфигурация Grafana

---

## Links

- [Grafana Docs](https://grafana.com/docs/grafana/latest/)
- [Loki Docs](https://grafana.com/docs/loki/latest/)
- [LogQL](https://grafana.com/docs/loki/latest/logql/)
- [Promtail](https://grafana.com/docs/loki/latest/clients/promtail/)
