# GitHub Secrets для CI/CD

## Необходимые Secrets

| Secret | Обязательность | Описание |
|--------|----------------|----------|
| `SSH_PRIVATE_KEY` | **Обязательно** | Приватный SSH ключ для доступа к VPS |
| `SSH_HOST` | **Обязательно** | IP адрес или домен VPS |
| `SSH_USER` | **Обязательно** | Пользователь SSH (`github-ci-cd-integration`) |
| `SSH_PORT` | Опционально | Порт SSH (default: 22) |
| `GRAFANA_ADMIN_PASSWORD` | **Обязательно** | Пароль admin в Grafana |
| `GRAFANA_ADMIN_USER` | Опционально | Username Grafana (default: admin) |
| `GRAFANA_API_KEY` | Опционально | API ключ для annotations (после 1-го деплоя) |

---

## Шаг 1: Генерация SSH ключей

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github_deploy_key -N ""
```

Создаст:
- `~/.ssh/github_deploy_key` — приватный (для GitHub Secret)
- `~/.ssh/github_deploy_key.pub` — публичный (для VPS)

---

## Шаг 2: Добавить публичный ключ на VPS

```bash
# Скопируй публичный ключ
cat ~/.ssh/github_deploy_key.pub

# Подключись к VPS
ssh your_user@your_server_ip

# Добавь ключ
sudo su - github-ci-cd-integration
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "PASTE_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit
```

---

## Шаг 3: Добавить Secrets в GitHub

**GitHub → Settings → Secrets and variables → Actions → New repository secret**

### SSH_PRIVATE_KEY
```bash
cat ~/.ssh/github_deploy_key
```
Скопируй **весь вывод** (включая `-----BEGIN...` и `-----END...`)

### SSH_HOST
IP адрес VPS: `123.45.67.89`

### SSH_USER
Значение: `github-ci-cd-integration`

### GRAFANA_ADMIN_PASSWORD
```bash
openssl rand -base64 32
```
Сохрани пароль в менеджер паролей!

### GRAFANA_API_KEY (опционально)
**Создавай ТОЛЬКО после 1-го деплоя:**

1. Открой https://proflyder.dev/grafana/
2. **Administration** → **Service accounts** → **Add service account**
3. Name: `GitHub Actions Deploy`, Role: `Editor`
4. **Add service account token** → Name: `deploy-annotations`
5. Скопируй токен

Подробно: `docs/GRAFANA_API_SETUP.md`

---

## Шаг 4: Проверка

```bash
# Проверь SSH подключение
ssh -i ~/.ssh/github_deploy_key github-ci-cd-integration@your_server_ip

# Проверь Secrets в GitHub
# Settings → Secrets → Actions: должны быть все обязательные секреты
```

---

## Запуск деплоя

```bash
# Auto-deploy при push в master
git push origin master

# Или вручную:
# GitHub → Actions → Deploy Monitoring Stack → Run workflow
```

---

## Troubleshooting

### Permission denied (publickey)
```bash
# Проверь authorized_keys
sudo cat /home/github-ci-cd-integration/.ssh/authorized_keys
```

### Connection timeout
```bash
# Проверь firewall
ssh github-ci-cd-integration@your_server_ip
sudo ufw allow 22/tcp
```

### Docker command not found
```bash
# Запусти setup скрипт
scp scripts/setup-vps.sh user@vps:/tmp/
ssh user@vps "sudo bash /tmp/setup-vps.sh"
```
