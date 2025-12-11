# 🚀 Quick Start Guide

## Первый запуск на production (VPS от ps.kz)

### 1. Настройка VPS сервера

```bash
# Подключитесь к VPS
ssh root@your_server_ip

# Скопируйте скрипт настройки с локальной машины
# (на локальной машине)
scp scripts/setup-vps.sh root@your_server_ip:/tmp/

# Запустите скрипт настройки на VPS
# (на VPS)
bash /tmp/setup-vps.sh

# Следуйте инструкциям скрипта
```

### 2. Настройка SSH ключей

```bash
# На локальной машине сгенерируйте SSH ключ для деплоя
ssh-keygen -t rsa -b 4096 -C "github-actions-deploy" -f ~/.ssh/github_deploy_key
# НЕ устанавливайте passphrase (просто Enter)

# Скопируйте публичный ключ
cat ~/.ssh/github_deploy_key.pub

# На VPS добавьте публичный ключ для пользователя deploy
ssh deploy@your_server_ip
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "ваш_публичный_ключ" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit

# Проверьте SSH подключение
ssh -i ~/.ssh/github_deploy_key deploy@your_server_ip
```

### 3. Настройка GitHub Secrets

Добавьте в GitHub → Settings → Secrets → Actions:

```
SSH_PRIVATE_KEY=<содержимое ~/.ssh/github_deploy_key>
SSH_HOST=<IP адрес вашего VPS>
SSH_USER=deploy
GRAFANA_ADMIN_PASSWORD=<надёжный пароль>
```

**Подробная инструкция:** [docs/GITHUB_SECRETS_SETUP.md](docs/GITHUB_SECRETS_SETUP.md)

### 4. Деплой через GitHub Actions

```bash
# Создайте репозиторий на GitHub (если еще не создан)
cd infra-monitoring
git add .
git commit -m "Configure monitoring for VPS"
git push origin master

# GitHub Actions автоматически задеплоит на VPS
# Смотрите прогресс: GitHub → Actions → Deploy Monitoring Stack
```

### 5. Настройка Nginx на VPS

```bash
# SSH на VPS
ssh deploy@your_server_ip

# Откройте конфиг nginx
sudo nano /etc/nginx/sites-available/proflyder.dev

# Добавьте блок location из config/nginx-grafana.conf

# Проверьте конфиг
sudo nginx -t

# Перезагрузите nginx
sudo systemctl reload nginx
```

### 6. Откройте Grafana

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
