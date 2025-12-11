#!/bin/bash
set -e

echo '🧹 Cleaning up old Docker images...'

# Удаляем dangling образы (без тегов)
sudo docker image prune -f

# Удаляем старые образы config (кроме текущего и backup)
CURRENT_IMAGE=$(grep "^Image:" /opt/monitoring/DEPLOYED_VERSION | cut -d' ' -f2 | cut -d':' -f2)
BACKUP_IMAGE=$(grep "^Image:" /opt/monitoring/DEPLOYED_VERSION.backup 2>/dev/null | cut -d' ' -f2 | cut -d':' -f2 || echo "none")

echo "Current tag: $CURRENT_IMAGE"
echo "Backup tag: $BACKUP_IMAGE"
echo ''

# Получаем все config образы
CONFIG_IMAGES=$(sudo docker images --format "{{.Repository}}:{{.Tag}}" | grep "infra-monitoring-config" || true)

for image in $CONFIG_IMAGES; do
  TAG=$(echo "$image" | cut -d':' -f2)
  if [ "$TAG" != "$CURRENT_IMAGE" ] && [ "$TAG" != "$BACKUP_IMAGE" ] && [ "$TAG" != "latest" ]; then
    echo "Removing old image: $image"
    sudo docker rmi "$image" 2>/dev/null || true
  fi
done

echo '✅ Cleanup completed!'
