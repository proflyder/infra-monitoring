#!/bin/bash
set -e

# Сохраняем текущую версию если она существует
if [ -f /opt/monitoring/DEPLOYED_VERSION ]; then
  sudo cp /opt/monitoring/DEPLOYED_VERSION /opt/monitoring/DEPLOYED_VERSION.backup
  echo "✅ Current version backed up"
else
  echo "ℹ️  No previous version to backup (first deploy)"
fi
