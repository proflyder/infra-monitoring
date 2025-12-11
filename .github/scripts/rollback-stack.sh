#!/bin/bash
set -e

# Принимаем параметры через environment variables:
# - GRAFANA_USER
# - GRAFANA_PASSWORD

echo '⚠️  Deployment or smoke tests failed! Rolling back...'
echo ''

if [ -f /opt/monitoring/DEPLOYED_VERSION.backup ]; then
  echo '═══════════════════════════════════════════════════════'
  echo '📋 Rollback Info'
  echo '═══════════════════════════════════════════════════════'
  echo 'Previous version (will be restored):'
  cat /opt/monitoring/DEPLOYED_VERSION.backup
  echo '═══════════════════════════════════════════════════════'
  echo ''

  echo '📦 Restoring previous version info...'
  sudo cp /opt/monitoring/DEPLOYED_VERSION.backup /opt/monitoring/DEPLOYED_VERSION

  # Извлекаем предыдущий образ из backup
  PREVIOUS_IMAGE=$(grep "^Image:" /opt/monitoring/DEPLOYED_VERSION | cut -d' ' -f2)

  if [ -n "$PREVIOUS_IMAGE" ]; then
    echo "⬇️  Pulling previous config image: $PREVIOUS_IMAGE"
    sudo docker pull "$PREVIOUS_IMAGE" || echo "⚠️  Could not pull previous image, using existing configs"

    echo '📦 Extracting previous configs...'
    sudo docker run --rm -v /opt/monitoring:/output "$PREVIOUS_IMAGE" || echo "⚠️  Using existing configs"
  fi

  echo '📝 Restoring .env file...'
  sudo tee /opt/monitoring/.env > /dev/null <<EOF
GRAFANA_ADMIN_USER=${GRAFANA_USER:-admin}
GRAFANA_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
TZ=Asia/Almaty
EOF

  echo '🐳 Restarting with previous version...'
  cd /opt/monitoring
  sudo docker compose down
  sudo docker compose up -d

  echo '⏳ Waiting for services to start...'
  sleep 20

  echo ''
  echo '✅ Rollback completed!'
  echo ''
  echo '📝 Restored version info:'
  cat /opt/monitoring/DEPLOYED_VERSION
else
  echo '❌ No previous version found to rollback to!'
  echo 'This might be the first deployment.'
  exit 1
fi
