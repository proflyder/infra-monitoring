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

# ═══════════════════════════════════════════════════════════════════
# Stage 1: Build dashboards from Jsonnet
# ═══════════════════════════════════════════════════════════════════
FROM golang:1.23-alpine AS jsonnet-builder

RUN apk add --no-cache git make

# Install jsonnet and jsonnet-bundler
RUN go install github.com/google/go-jsonnet/cmd/jsonnet@latest && \
    go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest

WORKDIR /build

# Copy dependency files first (for better layer caching)
COPY jsonnetfile.json ./

# Install grafonnet library (cached separately from source code)
RUN jb install

# Copy source files and Makefile
COPY Makefile ./
COPY dashboards-jsonnet/ ./dashboards-jsonnet/

# Build dashboards
RUN make dashboards && echo "✅ Dashboards built successfully"

# ═══════════════════════════════════════════════════════════════════
# Stage 2: Final config image
# ═══════════════════════════════════════════════════════════════════
FROM alpine:3.19

WORKDIR /configs

# Копируем docker-compose.yml
COPY docker-compose.yml ./

# Копируем конфиги (кроме dashboards - их берем из build stage)
COPY config/grafana/grafana.ini ./config/grafana/
COPY config/grafana/provisioning/ ./config/grafana/provisioning/
COPY config/loki-config.yml ./config/
COPY config/prometheus.yml ./config/

# Копируем сгенерированные дашборды из jsonnet-builder stage
COPY --from=jsonnet-builder /build/config/grafana/dashboards/ ./config/grafana/dashboards/

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
