# 🚀 Quick Start Guide

## Первый запуск на production (GCP VM)

### 1. Настройка GitHub Secrets

Добавьте в GitHub → Settings → Secrets → Actions:

```
GCC_TOKEN=<ваш Google Cloud credentials JSON>
GCC_VM_NAME=<имя VM>
GCC_VM_ZONE=<зона VM, например us-central1-a>
GRAFANA_ADMIN_PASSWORD=<надёжный пароль>
```

### 2. Деплой

```bash
# Создайте репозиторий на GitHub
gh repo create infra-monitoring --public

# Инициализируйте Git
cd infra-monitoring
git init
git add .
git commit -m "Initial commit: monitoring stack"
git branch -M main
git remote add origin https://github.com/your-username/infra-monitoring.git
git push -u origin main

# GitHub Actions автоматически задеплоит на GCP VM
```

### 3. Настройка Nginx на VM

```bash
# SSH на VM
gcloud compute ssh your-vm-name --zone=your-zone

# Откройте конфиг nginx
sudo nano /etc/nginx/sites-available/proflyder.dev

# Добавьте блок location из config/nginx-grafana.conf

# Проверьте конфиг
sudo nginx -t

# Перезагрузите nginx
sudo systemctl reload nginx
```

### 4. Откройте Grafana

```
URL: https://proflyder.dev/grafana/
Логин: admin
Пароль: (из GRAFANA_ADMIN_PASSWORD)
```

---

## Подключение Currency Bot

### 1. В проекте proflyder-tgbot уже добавлен Promtail

Файлы уже созданы:
- `docker compose.yml` - добавлен сервис promtail
- `config/promtail-config.yml` - конфигурация

### 2. Задеплойте currency-bot

```bash
cd proflyder-tgbot
git add .
git commit -m "Add Promtail for log shipping"
git push origin master

# CI/CD задеплоит бота с Promtail
```

### 3. Проверьте логи в Grafana

```
1. Откройте Grafana → Explore
2. Выберите Loki datasource
3. Запрос: {job="currency-bot"}
4. Должны появиться логи!
```

---

## Troubleshooting

### Логи не появляются в Grafana

```bash
# На VM проверьте Loki
curl http://localhost:3100/ready

# Проверьте Grafana
curl http://localhost:3000/api/health

# Проверьте логи Promtail в currency-bot
docker logs promtail-currency-bot

# Проверьте что Promtail может достучаться до Loki
docker exec promtail-currency-bot wget -O- http://host.docker.internal:3100/ready
```

### 502 Bad Gateway при открытии Grafana

```bash
# Проверьте что контейнер запущен
docker ps | grep grafana

# Проверьте nginx конфиг
sudo nginx -t
```

---

## Полезные команды

```bash
# Проверить статус мониторинга на VM
cd /opt/monitoring
docker compose ps
docker compose logs -f

# Перезапустить мониторинг
docker compose restart

# Обновить конфиги (после git push)
# GitHub Actions сделает это автоматически

# Посмотреть размер логов в Loki
docker exec loki du -sh /loki
```

---

## Следующие шаги

✅ Мониторинг работает
✅ Логи currency-bot собираются

Можно добавить:
- [ ] Создать дашборды в Grafana
- [ ] Настроить алерты
- [ ] Добавить Prometheus для метрик
- [ ] Подключить другие проекты

---

**Готово! 🎉**

Подробная документация: [README.md](README.md)
