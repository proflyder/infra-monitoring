# Настройка GitHub Secrets для CI/CD

Это руководство поможет настроить GitHub Secrets для автоматического деплоя мониторинга на VPS сервер.

## Зачем нужны GitHub Secrets?

GitHub Secrets — это безопасное хранилище конфиденциальной информации (ключи, пароли, токены), которые используются в GitHub Actions для деплоя.

## Необходимые Secrets

Для работы CI/CD pipeline нужны следующие секреты:

| Secret | Обязательность | Описание | Пример значения |
|--------|----------------|----------|-----------------|
| `SSH_PRIVATE_KEY` | **Обязательно** | Приватный SSH ключ для доступа к VPS | Содержимое файла `~/.ssh/id_rsa` |
| `SSH_HOST` | **Обязательно** | IP адрес или домен VPS сервера | `123.45.67.89` или `server.example.com` |
| `SSH_USER` | **Обязательно** | Пользователь для SSH подключения | `deploy` |
| `SSH_PORT` | Опционально | Порт SSH (по умолчанию: 22) | `22` или `2222` |
| `GRAFANA_ADMIN_USER` | Опционально | Username для Grafana (по умолчанию: admin) | `admin` |
| `GRAFANA_ADMIN_PASSWORD` | **Обязательно** | Пароль для Grafana admin пользователя | `YourSecurePassword123` |

---

## Шаг 1: Генерация SSH ключей

Если у тебя уже есть SSH ключ, можешь пропустить этот шаг.

### На локальной машине выполни:

```bash
# Генерация нового SSH ключа для деплоя
ssh-keygen -t rsa -b 4096 -C "github-actions-deploy" -f ~/.ssh/github_deploy_key

# НЕ устанавливай passphrase (просто нажми Enter)
# GitHub Actions не может работать с ключами, защищенными паролем
```

Это создаст два файла:
- `~/.ssh/github_deploy_key` — приватный ключ (будет добавлен в GitHub Secrets)
- `~/.ssh/github_deploy_key.pub` — публичный ключ (будет добавлен на VPS)

---

## Шаг 2: Добавление публичного ключа на VPS

Публичный ключ нужно добавить на VPS сервер.

### Вариант A: Через SSH (если у тебя уже есть доступ к серверу)

```bash
# Скопируй публичный ключ в буфер обмена
cat ~/.ssh/github_deploy_key.pub

# Подключись к VPS
ssh your_user@your_server_ip

# Добавь ключ в authorized_keys для пользователя deploy
sudo su - deploy
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "твой_публичный_ключ_здесь" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit
```

### Вариант B: Через панель управления хостинга

Если у ps.kz есть веб-панель управления, добавь публичный ключ через неё:
1. Открой панель управления VPS
2. Найди раздел "SSH Keys" или "Security"
3. Добавь публичный ключ из файла `~/.ssh/github_deploy_key.pub`

---

## Шаг 3: Добавление Secrets в GitHub

### 3.1 Открой настройки репозитория

1. Перейди в репозиторий: `https://github.com/your-username/infra-monitoring`
2. Нажми **Settings** (Настройки)
3. В левом меню выбери **Secrets and variables** → **Actions**
4. Нажми **New repository secret**

### 3.2 Добавь каждый Secret

#### SSH_PRIVATE_KEY

```bash
# На локальной машине выполни:
cat ~/.ssh/github_deploy_key
```

Скопируй **весь вывод** (включая `-----BEGIN RSA PRIVATE KEY-----` и `-----END RSA PRIVATE KEY-----`)

В GitHub:
- **Name:** `SSH_PRIVATE_KEY`
- **Value:** Вставь скопированный приватный ключ

#### SSH_HOST

- **Name:** `SSH_HOST`
- **Value:** IP адрес твоего VPS (например: `123.45.67.89`)

Узнать IP можно:
```bash
# Из панели управления ps.kz
# Или если уже подключен к серверу:
curl ifconfig.me
```

#### SSH_USER

- **Name:** `SSH_USER`
- **Value:** `deploy`

Это пользователь, который был создан скриптом `setup-vps.sh`

#### SSH_PORT (опционально)

Если используешь нестандартный SSH порт:
- **Name:** `SSH_PORT`
- **Value:** `22` (или другой порт, например `2222`)

#### GRAFANA_ADMIN_PASSWORD

```bash
# Сгенерируй надежный пароль:
openssl rand -base64 32
```

- **Name:** `GRAFANA_ADMIN_PASSWORD`
- **Value:** Сгенерированный пароль

**ВАЖНО:** Сохрани этот пароль в надежное место (менеджер паролей)!

#### GRAFANA_ADMIN_USER (опционально)

Если хочешь использовать другой логин вместо `admin`:
- **Name:** `GRAFANA_ADMIN_USER`
- **Value:** `admin` (или другой логин)

---

## Шаг 4: Проверка настроек

### Проверь SSH подключение локально

```bash
# Проверь, что можешь подключиться к VPS с новым ключом
ssh -i ~/.ssh/github_deploy_key deploy@your_server_ip

# Если подключение успешно — все настроено правильно!
```

### Проверь Secrets в GitHub

1. Открой **Settings** → **Secrets and variables** → **Actions**
2. Убедись, что все необходимые секреты добавлены:
   - ✅ SSH_PRIVATE_KEY
   - ✅ SSH_HOST
   - ✅ SSH_USER
   - ✅ GRAFANA_ADMIN_PASSWORD

---

## Шаг 5: Запуск первого деплоя

### Вариант A: Автоматический деплой (через push)

```bash
# Любой коммит в ветку master запустит деплой
git add .
git commit -m "Setup CI/CD for VPS"
git push origin master
```

### Вариант B: Ручной запуск

1. Открой GitHub → **Actions**
2. Выбери **Deploy Monitoring Stack**
3. Нажми **Run workflow** → **Run workflow**
4. Дождись завершения деплоя

### Просмотр логов деплоя

1. Открой **Actions** в репозитории
2. Кликни на последний workflow run
3. Раскрой каждый шаг для просмотра логов

---

## Troubleshooting

### ❌ ERROR: Permission denied (publickey)

**Причина:** Публичный ключ не добавлен на VPS или добавлен неправильно

**Решение:**
```bash
# Проверь на VPS:
sudo cat /home/deploy/.ssh/authorized_keys

# Убедись что там есть твой публичный ключ:
cat ~/.ssh/github_deploy_key.pub

# Если ключа нет — добавь его заново (см. Шаг 2)
```

### ❌ ERROR: SSH_PRIVATE_KEY secret is not set

**Причина:** Secret не добавлен в GitHub или назван неправильно

**Решение:**
1. Открой **Settings** → **Secrets and variables** → **Actions**
2. Проверь что секрет называется **точно** `SSH_PRIVATE_KEY` (с подчеркиванием, не дефисом)
3. Если секрета нет — добавь его (см. Шаг 3)

### ❌ Deployment failed: Connection timeout

**Причина:** Неверный IP адрес, порт или firewall блокирует соединение

**Решение:**
```bash
# Проверь IP адрес сервера:
# Должен быть доступен извне (не 127.0.0.1 или 192.168.x.x)

# Проверь firewall на VPS:
ssh deploy@your_server_ip
sudo ufw status

# Убедись что порт 22 (SSH) открыт:
sudo ufw allow 22/tcp
```

### ❌ Docker command not found

**Причина:** Docker не установлен на VPS или пользователь deploy не в группе docker

**Решение:**
```bash
# Подключись к VPS:
ssh deploy@your_server_ip

# Проверь установлен ли Docker:
docker --version

# Если нет — запусти скрипт настройки VPS:
# (на локальной машине)
scp scripts/setup-vps.sh deploy@your_server_ip:/tmp/
ssh deploy@your_server_ip "sudo bash /tmp/setup-vps.sh"
```

---

## Безопасность

### Рекомендации:

1. **НЕ используй корневой SSH ключ** — создай отдельный для GitHub Actions
2. **Используй надежный пароль для Grafana** — минимум 16 символов
3. **Регулярно ротируй секреты** — обновляй SSH ключи раз в полгода
4. **Ограничь права пользователя deploy** — только docker и nginx команды (уже настроено в `setup-vps.sh`)
5. **Включи 2FA в GitHub** — защити доступ к репозиторию

### Что делать если ключ скомпрометирован:

```bash
# 1. Удали старый ключ с VPS
ssh your_user@your_server_ip
sudo nano /home/deploy/.ssh/authorized_keys
# Удали скомпрометированный ключ

# 2. Создай новую пару ключей (см. Шаг 1)

# 3. Добавь новый публичный ключ на VPS (см. Шаг 2)

# 4. Обнови SSH_PRIVATE_KEY секрет в GitHub (см. Шаг 3.2)

# 5. Запусти деплой снова
```

---

## Дополнительные материалы

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [SSH Key Authentication](https://www.ssh.com/academy/ssh/public-key-authentication)

---

Если возникли вопросы или проблемы — создай Issue в репозитории.