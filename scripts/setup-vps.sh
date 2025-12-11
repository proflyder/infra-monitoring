#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# Скрипт первоначальной настройки VPS сервера для мониторинга
# ═══════════════════════════════════════════════════════════════════
#
# Что делает этот скрипт:
# 1. Обновляет систему
# 2. Устанавливает Docker и Docker Compose v2
# 3. Настраивает firewall (UFW)
# 4. Создает пользователя для деплоя
# 5. Настраивает SSH доступ
# 6. Создает директории для мониторинга
# 7. Устанавливает и настраивает nginx
#
# Использование:
#   chmod +x setup-vps.sh
#   sudo ./setup-vps.sh
#
# ═══════════════════════════════════════════════════════════════════

set -e  # Остановка при ошибке

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка что запущено от root
if [ "$EUID" -ne 0 ]; then
    echo_error "Скрипт должен быть запущен с sudo или от root"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════════
# 1. Обновление системы
# ═══════════════════════════════════════════════════════════════════
echo_info "Обновление системы..."
apt-get update
apt-get upgrade -y

# Установка базовых пакетов
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    ufw \
    ca-certificates \
    gnupg \
    lsb-release

# ═══════════════════════════════════════════════════════════════════
# 2. Установка Docker
# ═══════════════════════════════════════════════════════════════════
echo_info "Установка Docker..."

# Удаление старых версий
apt-get remove -y docker docker-engine docker.io containerd runc || true

# Добавление репозитория Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Установка Docker
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Проверка установки
docker --version
docker compose version

echo_info "Docker установлен успешно"

# ═══════════════════════════════════════════════════════════════════
# 3. Настройка Firewall (UFW)
# ═══════════════════════════════════════════════════════════════════
echo_info "Настройка Firewall..."

# Включаем UFW
ufw --force enable

# Базовые правила
ufw default deny incoming
ufw default allow outgoing

# Разрешаем SSH
ufw allow 22/tcp

# Разрешаем HTTP и HTTPS для nginx
ufw allow 80/tcp
ufw allow 443/tcp

# Применяем правила
ufw reload

echo_info "Firewall настроен"

# ═══════════════════════════════════════════════════════════════════
# 4. Создание пользователя для деплоя
# ═══════════════════════════════════════════════════════════════════
DEPLOY_USER="github-ci-cd-integration"

if id "$DEPLOY_USER" &>/dev/null; then
    echo_warn "Пользователь $DEPLOY_USER уже существует"
else
    echo_info "Создание пользователя $DEPLOY_USER..."

    # Создаем пользователя без интерактивного ввода пароля
    useradd -m -s /bin/bash "$DEPLOY_USER"

    # Добавляем в группу docker
    usermod -aG docker "$DEPLOY_USER"

    # Даем sudo права без пароля для docker команд
    echo "$DEPLOY_USER ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/docker compose, /usr/bin/systemctl reload nginx, /usr/bin/systemctl restart nginx" > /etc/sudoers.d/$DEPLOY_USER
    chmod 0440 /etc/sudoers.d/$DEPLOY_USER

    echo_info "Пользователь $DEPLOY_USER создан"
fi

# ═══════════════════════════════════════════════════════════════════
# 5. Настройка SSH для пользователя deploy
# ═══════════════════════════════════════════════════════════════════
echo_info "Настройка SSH для пользователя $DEPLOY_USER..."

# Создаем .ssh директорию
DEPLOY_HOME="/home/$DEPLOY_USER"
mkdir -p "$DEPLOY_HOME/.ssh"
touch "$DEPLOY_HOME/.ssh/authorized_keys"
chmod 700 "$DEPLOY_HOME/.ssh"
chmod 600 "$DEPLOY_HOME/.ssh/authorized_keys"
chown -R $DEPLOY_USER:$DEPLOY_USER "$DEPLOY_HOME/.ssh"

echo_info "SSH директория создана: $DEPLOY_HOME/.ssh"
echo_warn "ВАЖНО: Добавь свой публичный SSH ключ в $DEPLOY_HOME/.ssh/authorized_keys"
echo_warn "Пример: echo 'ssh-rsa AAAA...' >> $DEPLOY_HOME/.ssh/authorized_keys"

# ═══════════════════════════════════════════════════════════════════
# 6. Создание директорий для мониторинга
# ═══════════════════════════════════════════════════════════════════
echo_info "Создание директорий для мониторинга..."

mkdir -p /opt/monitoring
chown -R $DEPLOY_USER:$DEPLOY_USER /opt/monitoring
chmod 755 /opt/monitoring

echo_info "Директория /opt/monitoring создана"

# ═══════════════════════════════════════════════════════════════════
# 7. Установка nginx
# ═══════════════════════════════════════════════════════════════════
echo_info "Установка nginx..."

apt-get install -y nginx

# Базовая настройка nginx
cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# Перезапускаем nginx
systemctl enable nginx
systemctl restart nginx

echo_info "nginx установлен и запущен"
echo_warn "Для настройки Grafana добавь конфиг из config/nginx-grafana.conf"

# ═══════════════════════════════════════════════════════════════════
# 8. Настройка лимитов для Docker
# ═══════════════════════════════════════════════════════════════════
echo_info "Настройка лимитов для Docker..."

# Увеличиваем лимиты для файловых дескрипторов
cat >> /etc/security/limits.conf <<EOF

# Docker limits
* soft nofile 65536
* hard nofile 65536
* soft nproc 4096
* hard nproc 4096
EOF

echo_info "Лимиты настроены"

# ═══════════════════════════════════════════════════════════════════
# 9. Настройка автоматических обновлений безопасности
# ═══════════════════════════════════════════════════════════════════
echo_info "Настройка автоматических обновлений..."

apt-get install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades

echo_info "Автоматические обновления безопасности включены"

# ═══════════════════════════════════════════════════════════════════
# Итоговая информация
# ═══════════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ Сервер настроен успешно!${NC}"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Следующие шаги:"
echo ""
echo "1. Добавь SSH ключ для деплоя:"
echo "   На локальной машине выполни:"
echo "   cat ~/.ssh/id_rsa.pub"
echo ""
echo "   На сервере выполни:"
echo "   echo 'твой_публичный_ключ' >> $DEPLOY_HOME/.ssh/authorized_keys"
echo ""
echo "2. Проверь SSH доступ:"
echo "   ssh $DEPLOY_USER@your_server_ip"
echo ""
echo "3. Настрой GitHub Secrets в репозитории:"
echo "   - SSH_PRIVATE_KEY: приватный SSH ключ"
echo "   - SSH_HOST: IP адрес сервера"
echo "   - SSH_USER: $DEPLOY_USER"
echo "   - GRAFANA_ADMIN_PASSWORD: пароль для Grafana"
echo ""
echo "4. Настрой домен и SSL сертификат:"
echo "   sudo apt install certbot python3-certbot-nginx"
echo "   sudo certbot --nginx -d your_domain.com"
echo ""
echo "5. Добавь конфиг nginx для Grafana:"
echo "   См. config/nginx-grafana.conf в репозитории"
echo ""
echo "6. Запусти деплой через GitHub Actions"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Установленные версии:"
docker --version
docker compose version
nginx -v
echo ""
echo "Статус сервисов:"
systemctl is-active docker
systemctl is-active nginx
echo ""
echo "═══════════════════════════════════════════════════════════════════"