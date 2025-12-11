# ═══════════════════════════════════════════════════════════════════
# Configuration Docker Image для Monitoring Stack
# ═══════════════════════════════════════════════════════════════════
#
# Этот образ содержит только конфигурационные файлы для мониторинга.
# На VPS мы копируем конфиги из этого образа и запускаем docker-compose.
#
# Использование:
#   docker build -t ghcr.io/username/infra-monitoring-config:latest .
#   docker push ghcr.io/username/infra-monitoring-config:latest
#
# На VPS:
#   docker pull ghcr.io/username/infra-monitoring-config:latest
#   docker run --rm -v /tmp/configs:/output ghcr.io/username/infra-monitoring-config:latest
#
# ═══════════════════════════════════════════════════════════════════

FROM alpine:3.19

WORKDIR /configs

# Копируем все конфигурационные файлы
COPY docker-compose.yml ./
COPY config/ ./config/

# Создаем скрипт для копирования конфигов
RUN cat > /extract-configs.sh <<'EOF'
#!/bin/sh
if [ -d "/output" ]; then
  echo "Copying configs to /output..."
  cp -r /configs/* /output/
  echo "✅ Configs extracted successfully!"
else
  echo "❌ /output directory not mounted!"
  exit 1
fi
EOF

RUN chmod +x /extract-configs.sh

# При запуске копируем конфиги в /output (который будет volume)
CMD ["/extract-configs.sh"]
