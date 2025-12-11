# Grafana Дашборды: Jsonnet + Grafonnet

Дашборды автоматически собираются из Jsonnet в CI/CD pipeline.

## Быстрый старт

### Локальная разработка

```bash
# С Docker (рекомендуется)
make dashboards-docker

# Или локально
brew install jsonnet jsonnet-bundler  # macOS
make install-deps && make dashboards
```

### Workflow

1. Редактируй `.jsonnet` в `dashboards-jsonnet/`
2. Запусти `make dashboards-docker`
3. Grafana подхватит изменения через 10 сек
4. Коммить **только** `.jsonnet` (JSON генерируется в CI/CD)

```bash
git add dashboards-jsonnet/
git commit -m "Update dashboards"
git push
```

## Преимущества

**До:** 1104 строк JSON → **После:** 489 строк Jsonnet (**56% меньше**)

- ✅ Переиспользуемые компоненты (`lib/common.libsonnet`)
- ✅ Параметризация (одна функция для USD/KZT и RUB/KZT)
- ✅ Git-friendly diff'ы
- ✅ Автосборка в CI/CD (Docker multi-stage build)

## Структура

```
dashboards-jsonnet/
├── lib/common.libsonnet         # Общие компоненты
├── infra/system.jsonnet         # VM System Metrics
└── proflyder-service/
    ├── api.jsonnet              # API Requests
    ├── logs.jsonnet             # Application Logs
    └── currency.jsonnet         # Exchange Rates
```

## Пример

### До (JSON, 70 строк)
```json
{
  "type": "timeseries",
  "title": "CPU Usage Over Time (%)",
  "datasource": {"type": "prometheus", "uid": "prometheus"},
  "targets": [{
    "expr": "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
    "legendFormat": "Total CPU Usage"
  }],
  "options": {...},
  "fieldConfig": {...}
}
```

### После (Jsonnet, 15 строк)
```jsonnet
common.defaultTimeseries('CPU Usage Over Time (%)', prometheus)
+ g.panel.timeSeries.queryOptions.withTargets([
  g.query.prometheus.new(prometheus.uid,
    '100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)'
  )
  + g.query.prometheus.withLegendFormat('Total CPU Usage'),
])
+ g.panel.timeSeries.standardOptions.withUnit('percent')
```

## CI/CD Pipeline

**Автоматически при push в master:**

1. Docker multi-stage build:
   - Stage 1: Устанавливает jsonnet/jb → собирает JSON
   - Stage 2: Копирует конфиги + JSON → финальный образ
2. Push в GHCR
3. Deploy на VPS с готовыми дашбордами

**Время сборки:**
- Первая: ~2-3 минуты
- Повторная (только .jsonnet): ~30-60 секунд

## Создание нового дашборда

```jsonnet
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = import '../lib/common.libsonnet';

common.defaultDashboard('My Dashboard', tags=['tag'], uid='my-dash')
+ g.dashboard.withPanels([
  common.defaultTimeseries('My Panel', common.datasources.prometheus)
  + g.panel.timeSeries.queryOptions.withTargets([
    g.query.prometheus.new('prometheus', 'my_metric'),
  ]),
])
```

Затем: `make dashboards-docker` → проверь в Grafana → коммить.

## Компоненты в common.libsonnet

**Datasources:**
- `common.datasources.prometheus`
- `common.datasources.loki`

**Panels:**
- `defaultTimeseries(title, datasource)` - timeseries панель
- `defaultGauge(title, datasource)` - gauge
- `defaultLogs(title, datasource)` - logs
- `defaultStat(title, datasource)` - stat

**Thresholds:**
- `thresholds.cpu` - 70% yellow, 90% red
- `thresholds.memory` - 75% yellow, 90% red

## Troubleshooting

### Ошибка импорта grafonnet
```
couldn't open import "grafonnet/main.libsonnet"
```

**Решение:** Используй полный путь:
```jsonnet
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
```

### Дашборды не обновляются в Grafana
1. Подожди 10 секунд (provisioning interval)
2. Проверь GitHub Actions: build успешен?
3. На VPS: `ls config/grafana/dashboards/*/*.json`

### `jsonnet: command not found`
```bash
# Docker (не требует установки)
make dashboards-docker

# Или установи локально
brew install jsonnet jsonnet-bundler
make install-deps
```

## Проверка работы

**Локально:**
```bash
docker build -t test .
docker run --rm test sh -c "ls /configs/config/grafana/dashboards/*/*.json"
# Должно показать 4 файла
```

**В CI:**
Смотри GitHub Actions logs для:
```
✅ Dashboards built successfully
```

**На VPS:**
```bash
ssh vps
ls -lh /opt/monitoring/config/grafana/dashboards/*/*.json
```

## Ссылки

- [Jsonnet Tutorial](https://jsonnet.org/learning/tutorial.html)
- [Grafonnet Docs](https://grafana.github.io/grafonnet/)
- Детали: [dashboards-jsonnet/README.md](../dashboards-jsonnet/README.md)
