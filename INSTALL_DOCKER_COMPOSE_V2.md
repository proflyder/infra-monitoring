# Установка Docker Compose v2 на GCP VM

## Проблема

Если вы видите ошибку:
```
ModuleNotFoundError: No module named 'distutils'
```

Это значит что у вас установлена старая версия `docker-compose` v1 (1.29.2), которая несовместима с Python 3.12.

## Решение: Установить Docker Compose v2

Docker Compose v2 - это современная версия, которая работает как плагин Docker.

### Шаг 1: SSH на VM

```bash
gcloud compute ssh your-vm-name --zone=your-zone
```

### Шаг 2: Удалить старый docker-compose

```bash
# Проверить текущую версию
docker-compose --version
# docker-compose version 1.29.2

# Удалить старую версию
sudo apt remove docker-compose -y
```

### Шаг 3: Установить Docker Compose v2

```bash
# Обновить пакеты
sudo apt update

# Установить docker-compose-plugin
sudo apt install docker-compose-plugin -y
```

### Шаг 4: Проверить установку

```bash
# Проверить версию (обратите внимание: пробел вместо дефиса!)
docker compose version
# Docker Compose version v2.24.5 (или новее)

# Проверить что работает
docker compose --help
```

## Разница между v1 и v2

| Версия | Команда | Статус |
|--------|---------|--------|
| v1 (старая) | `docker-compose` (с дефисом) | ❌ Deprecated |
| v2 (новая) | `docker compose` (с пробелом) | ✅ Актуальная |

## После установки

Теперь все команды используют **пробел** вместо дефиса:

```bash
# Старый синтаксис (не работает)
docker-compose up -d      # ❌

# Новый синтаксис (работает)
docker compose up -d      # ✅
```

## Если у вас несколько проектов

После обновления нужно обновить все проекты:

### 1. infra-monitoring ✅
Уже обновлён в этом PR.

### 2. proflyder-tgbot
Нужно обновить `docker-compose.yml` и CI/CD если есть.

```bash
cd /app/currency-bot
sudo docker compose down
sudo docker compose up -d
```

## Автоматическая установка (для новых VM)

Добавьте в ваш init script:

```bash
#!/bin/bash

# Установить Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Установить Docker Compose v2
sudo apt update
sudo apt install docker-compose-plugin -y

# Проверить
docker --version
docker compose version
```

## Troubleshooting

### "docker: 'compose' is not a docker command"

```bash
# Проверить что плагин установлен
dpkg -l | grep docker-compose-plugin

# Если не установлен:
sudo apt install docker-compose-plugin -y
```

### Старая команда docker-compose всё ещё работает

```bash
# Возможно установлен alias, проверьте:
alias | grep docker-compose

# Или установлен через pip:
pip3 list | grep docker-compose

# Удалите через pip:
sudo pip3 uninstall docker-compose
```

---

**После установки Docker Compose v2 проблема с `distutils` исчезнет!** 🎉
