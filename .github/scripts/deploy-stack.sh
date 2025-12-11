#!/bin/bash
set -e

# Принимаем параметры через environment variables:
# - CONFIG_IMAGE
# - GRAFANA_USER
# - GRAFANA_PASSWORD
# - GITHUB_TOKEN
# - GITHUB_ACTOR
# - COMMIT_SHA
# - COMMIT_MESSAGE

echo '═══════════════════════════════════════════════════════'
echo '📋 Deployment Info'
echo '═══════════════════════════════════════════════════════'
echo "Target image: $CONFIG_IMAGE"
echo "Commit: $COMMIT_SHA"
echo "Deploying by: $GITHUB_ACTOR"
echo ''
echo 'Current deployed version:'
if [ -f /opt/monitoring/DEPLOYED_VERSION ]; then
  cat /opt/monitoring/DEPLOYED_VERSION
else
  echo '  (No previous deployment)'
fi
echo '═══════════════════════════════════════════════════════'
echo ''

echo '📂 Creating monitoring directory...'
sudo mkdir -p /opt/monitoring

echo '📦 Logging in to GitHub Container Registry...'
echo "$GITHUB_TOKEN" | sudo docker login ghcr.io -u "$GITHUB_ACTOR" --password-stdin

echo '⬇️  Pulling config image from GHCR...'
sudo docker pull "$CONFIG_IMAGE"

echo '📦 Extracting configs from image...'
sudo docker run --rm -v /opt/monitoring:/output "$CONFIG_IMAGE"

echo '📝 Creating .env file...'
sudo tee /opt/monitoring/.env > /dev/null <<EOF
GRAFANA_ADMIN_USER=${GRAFANA_USER:-admin}
GRAFANA_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
TZ=Asia/Almaty
EOF

echo '🔒 Setting permissions...'
sudo chown -R $USER:$USER /opt/monitoring
sudo chmod 600 /opt/monitoring/.env

echo '📝 Saving deployment version info...'
sudo tee /opt/monitoring/DEPLOYED_VERSION > /dev/null <<EOF
Image: $CONFIG_IMAGE
Commit: $COMMIT_SHA
Message: $COMMIT_MESSAGE
Deployed: $(date -Iseconds)
Deployed by: $GITHUB_ACTOR
EOF

echo '🐳 Stopping old containers...'
cd /opt/monitoring
sudo docker compose down 2>/dev/null || true

echo '🐳 Starting monitoring stack...'
sudo docker compose up -d

echo '⏳ Waiting for services to start...'
sleep 30

echo '📊 Container status after startup:'
sudo docker compose ps

echo ''
echo '✅ Deployment completed!'
echo ''
echo '📝 Deployed version info:'
cat /opt/monitoring/DEPLOYED_VERSION
